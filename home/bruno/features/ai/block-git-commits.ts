import type { Plugin } from "@opencode-ai/plugin";

const providers: Record<string, { name: string; email: string }> = {
  anthropic: { name: "Claude", email: "noreply@anthropic.com" },
  openai: { name: "ChatGPT", email: "noreply@openai.com" },
  google: { name: "Gemini", email: "noreply@google.com" },
};

function formatCoAuthor(providerID: string, modelID: string): string {
  const provider = providers[providerID] ?? { name: providerID, email: `noreply@${providerID}.com` };
  return `Co-authored-by: ${provider.name} (${modelID}) <${provider.email}>`;
}

export const server: Plugin = async ({ client }) => ({
  "tool.execute.before": async (input, output) => {
    const tool = input.tool;
    const command: string = input.args?.command ?? output.args?.command ?? "";
    const stripped = command.replace(/'[^']*'|"[^"]*"/g, "");

    // Block git push via any tool
    if (/\bgit\s+push\b/.test(stripped)) {
      throw new Error("BLOCKED: git push não é permitido sem autorização explícita do usuário.");
    }

    // Block --author override via any tool
    if (/\bgit\s+commit\b/.test(stripped) && /(^|\s)--author(=|\s)/.test(stripped)) {
      throw new Error(
        "BLOCKED: não use --author. A identidade PrêdaCoder[bot] é definida pelo wrapper. Use Co-authored-by no corpo do commit."
      );
    }

    // Block git commit via bash — force usage of MCP git_commit
    if (/\bgit\s+commit\b/.test(stripped)) {
      throw new Error(
        "BLOCKED: use a tool mcp__git__git_commit para commits. Não execute git commit diretamente."
      );
    }

    // Inject Co-authored-by trailer on MCP git_commit
    if (tool === "git_git_commit") {
      const message: string = output.args?.message ?? "";
      if (!message) return;

      if (/^Co-authored-by:/m.test(message)) return;

      let modelID = "unknown";
      let providerID = "unknown";
      try {
        const sessionID = input.sessionID;
        const msgs = await client.session.messages({ path: { id: sessionID } });
        const last = (msgs.data as any[])?.findLast((m: any) => m.info?.role === "assistant");
        if (last?.info) {
          modelID = last.info.modelID ?? "unknown";
          providerID = last.info.providerID ?? "unknown";
        }
      } catch {}

      output.args.message = message.trimEnd() + "\n\n" + formatCoAuthor(providerID, modelID);
    }
  },
});
