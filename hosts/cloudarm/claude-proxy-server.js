#!/usr/bin/env node
const http = require("http");
const { spawn } = require("child_process");
const fs = require("fs");
const path = require("path");

const PORT = 3333;
const TOKEN = process.env.CLAUDE_PROXY_TOKEN;
const CLAUDE_BIN = "/run/current-system/sw/bin/claude";
const ALLOWED_MODELS = ["claude-sonnet-4-6", "claude-opus-4-6"];
const DEFAULT_MODEL = "claude-sonnet-4-6";
const TIMEOUT_MS = 300_000; // 5 min
const PROXY_HOME = "/root/claude-proxy/home";

if (!TOKEN) {
  console.error("CLAUDE_PROXY_TOKEN required");
  process.exit(1);
}

fs.mkdirSync(path.join(PROXY_HOME, ".claude"), { recursive: true });
const credsSrc = "/root/.claude/.credentials.json";
const credsDst = path.join(PROXY_HOME, ".claude", ".credentials.json");
if (fs.existsSync(credsSrc)) {
  fs.copyFileSync(credsSrc, credsDst);
  fs.chmodSync(credsDst, 0o600);
}

function readBody(req) {
  return new Promise((resolve, reject) => {
    const chunks = [];
    req.on("data", (c) => chunks.push(c));
    req.on("end", () => {
      try {
        resolve(JSON.parse(Buffer.concat(chunks).toString()));
      } catch {
        reject(new Error("Invalid JSON"));
      }
    });
    req.on("error", reject);
  });
}

function runClaude(prompt, schema, model) {
  return new Promise((resolve, reject) => {
    const args = [
      "-p",
      prompt,
      "--output-format",
      "json",
      "--json-schema",
      JSON.stringify(schema),
      "--model",
      model,
      "--no-session-persistence",
    ];
    let stdout = "",
      stderr = "";

    const child = spawn(CLAUDE_BIN, args, {
      env: { ...process.env, HOME: PROXY_HOME },
      stdio: ["ignore", "pipe", "pipe"],
    });

    child.stdout.on("data", (d) => {
      stdout += d;
    });
    child.stderr.on("data", (d) => {
      stderr += d;
    });

    const timer = setTimeout(() => {
      console.error(`[timeout] after ${TIMEOUT_MS}ms — stderr: ${stderr.slice(0, 500)}`);
      console.error(`[timeout] stdout so far: ${stdout.slice(0, 200)}`);
      child.kill("SIGKILL");
      reject(new Error("timeout"));
    }, TIMEOUT_MS);

    child.on("close", (code) => {
      clearTimeout(timer);
      if (code !== 0) return reject(new Error(stderr || `exit ${code}`));
      try {
        const parsed = JSON.parse(stdout);
        const costUsd = parsed.total_cost_usd ?? null;
        const usage = parsed.usage ?? {};
        const inputTokens = usage.input_tokens ?? 0;
        const outputTokens = usage.output_tokens ?? 0;
        const cacheRead = usage.cache_read_input_tokens ?? 0;
        const cacheCreate = usage.cache_creation_input_tokens ?? 0;
        console.log(
          `[cost] model=${model} cost_usd=${costUsd?.toFixed(6) ?? "n/a"} in=${inputTokens} out=${outputTokens} cache_read=${cacheRead} cache_create=${cacheCreate}`
        );
        resolve({
          result: parsed.structured_output ?? parsed.result ?? parsed,
          costUsd,
          inputTokens,
          outputTokens,
        });
      } catch {
        reject(new Error(`bad output: ${stdout.slice(0, 200)}`));
      }
    });
  });
}

const server = http.createServer(async (req, res) => {
  if ((req.headers["authorization"] ?? "") !== `Bearer ${TOKEN}`) {
    res.writeHead(401, { "Content-Type": "application/json" });
    return res.end(JSON.stringify({ error: "Unauthorized" }));
  }
  if (req.method !== "POST" || req.url !== "/enrich") {
    res.writeHead(404, { "Content-Type": "application/json" });
    return res.end(JSON.stringify({ error: "Not found" }));
  }
  try {
    const { prompt, schema, model: reqModel } = await readBody(req);
    if (!prompt || !schema) {
      res.writeHead(400, { "Content-Type": "application/json" });
      return res.end(JSON.stringify({ error: "prompt and schema required" }));
    }
    const model = ALLOWED_MODELS.includes(reqModel) ? reqModel : DEFAULT_MODEL;
    console.log(`[${new Date().toISOString()}] model=${model}`);
    const { result, costUsd, inputTokens, outputTokens } = await runClaude(prompt, schema, model);
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify({ result, costUsd, inputTokens, outputTokens }));
  } catch (err) {
    console.error(`[${new Date().toISOString()}] error: ${err.message}`);
    res.writeHead(500, { "Content-Type": "application/json" });
    res.end(JSON.stringify({ error: err.message }));
  }
});

server.listen(PORT, "0.0.0.0", () => console.log(`Claude proxy listening on :${PORT}`));
