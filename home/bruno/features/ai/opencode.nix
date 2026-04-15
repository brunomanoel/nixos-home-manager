{
  pkgs,
  ...
}:

let
  memoryInstructions = builtins.readFile ./memory-instructions.md;
  mcpReferenceDoc = builtins.readFile ./mcp-reference.md;
  themes = import ./opencode-themes.nix;

  # Plugin que bloqueia git commit sem --author="Claude <noreply@anthropic.com>"
  blockGitCommitsPlugin = pkgs.writeText "block-git-commits.ts" (
    builtins.readFile ./block-git-commits.ts
  );
in
{
  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;
    rules = memoryInstructions;
    tui = {
      theme = "dracula";
    };
    inherit themes;
    settings = {
      plugin = [
        "file://${pkgs.opencode-anthropic-auth}"
        "file://${blockGitCommitsPlugin}"
        "@mohak34/opencode-notifier"
      ];
      permission = {
        read."~/.config/opencode/get-shit-done/*" = "allow";
        external_directory."~/.config/opencode/get-shit-done/*" = "allow";
      };
      tools = {
        lsp = true;
      };
    };
  };

  home.file.".config/opencode/rules/mcp-reference.md".text = mcpReferenceDoc;
  home.file.".config/opencode/agents".source = "${pkgs.gsd}/share/opencode/agents";
  home.file.".config/opencode/command".source = "${pkgs.gsd}/share/opencode/command";
  home.file.".config/opencode/get-shit-done".source = "${pkgs.gsd}/share/opencode/get-shit-done";
}
