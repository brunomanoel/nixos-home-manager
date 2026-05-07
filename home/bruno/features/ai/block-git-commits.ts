import type { Plugin } from "@opencode-ai/plugin";

export const server: Plugin = async () => ({
  "tool.execute.before": async (input, output) => {
    const toolName = input.tool ?? "";

    // Block any MCP git push tool — pushes require explicit user authorization.
    if (toolName.includes("git_push") || toolName === "push") {
      throw new Error(
        "BLOCKED: git push via tool MCP não é permitido. Peça autorização explícita."
      );
    }

    if (toolName !== "bash") return;

    const command: string = output.args?.command ?? "";

    if (/git\s+push/.test(command)) {
      throw new Error("BLOCKED: git push não é permitido sem autorização explícita do usuário.");
    }
  },
});
