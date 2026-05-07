import type { Plugin } from "@opencode-ai/plugin";

export const server: Plugin = async () => ({
  "tool.execute.before": async (input, output) => {
    const command: string = input.args?.command ?? output.args?.command ?? "";

    const stripped = command.replace(/'[^']*'|"[^"]*"/g, "");

    if (/\bgit\s+push\b/.test(stripped)) {
      throw new Error("BLOCKED: git push não é permitido sem autorização explícita do usuário.");
    }

    if (/\bgit\s+commit\b/.test(stripped) && /(^|\s)--author(=|\s)/.test(stripped)) {
      throw new Error(
        "BLOCKED: não use --author. A identidade PrêdaCoder[bot] é definida pelo wrapper. Use Co-authored-by no corpo do commit."
      );
    }
  },
});
