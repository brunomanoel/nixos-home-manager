import type { Plugin } from "@opencode-ai/plugin"

export const server: Plugin = async () => ({
  "tool.execute.before": async (input, output) => {
    // Block MCP git commit tool entirely — it bypasses hooks and uses the local git user
    if (input.tool === "git_commit") {
      throw new Error(
        "BLOCKED: use bash git commit com --author, não o MCP git_commit.",
      )
    }

    if (input.tool !== "bash") return

    const command: string = output.args?.command ?? ""

    if (/git\s+commit/.test(command) && !command.includes("noreply@anthropic")) {
      throw new Error(
        'BLOCKED: git commit sem --author="Claude <noreply@anthropic.com>" não é permitido.',
      )
    }
  },
})
