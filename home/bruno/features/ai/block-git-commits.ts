import type { Plugin } from "@opencode-ai/plugin";

export const server: Plugin = async () => ({
  "tool.execute.before": async (input, output) => {
    const toolName = input.tool ?? "";

    // Block any MCP git commit tool — matches git_commit, mcp_Git_git_commit, etc.
    // These bypass --author and use the local git user.
    if (toolName.includes("git_commit")) {
      throw new Error(
        'BLOCKED: use bash git commit com --author="Claude <noreply@anthropic.com>", não a tool MCP.'
      );
    }

    // Block any MCP git push tool — pushes require explicit user authorization.
    if (toolName.includes("git_push") || toolName === "push") {
      throw new Error(
        "BLOCKED: git push via tool MCP não é permitido. Peça autorização explícita."
      );
    }

    if (toolName !== "bash") return;

    const command: string = output.args?.command ?? "";

    if (/git\s+commit/.test(command) && !command.includes("noreply@anthropic")) {
      throw new Error(
        'BLOCKED: git commit sem --author="Claude <noreply@anthropic.com>" não é permitido.'
      );
    }

    if (/git\s+push/.test(command)) {
      throw new Error("BLOCKED: git push não é permitido sem autorização explícita do usuário.");
    }
  },
});
