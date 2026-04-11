import type { Plugin } from "@opencode-ai/plugin"

export const server: Plugin = async () => ({
  "tool.execute.before": async (input, output) => {
    if (input.tool !== "bash") return

    const command: string = output.args?.command ?? ""

    if (/git\s+commit/.test(command) && !command.includes("noreply@anthropic")) {
      throw new Error(
        'BLOCKED: git commit sem --author="Claude <noreply@anthropic.com>" não é permitido.',
      )
    }
  },
})
