{
  pkgs,
  ...
}:

let
  memoryInstructions = builtins.readFile ./memory-instructions.md;
  mcpReferenceDoc = builtins.readFile ./mcp-reference.md;
  themes = import ./opencode-themes.nix;

  # Plugin that blocks git commits without --author="Claude <noreply@anthropic.com>"
  blockGitCommitsPlugin = pkgs.writeText "block-git-commits.ts" (
    builtins.readFile ./block-git-commits.ts
  );

  # Opencode plugins (oh-my-openagent, msgpackr-extract from auth/notifier
  # plugins) ship native .node bindings linked against system libstdc++.
  # The opencode binary itself is nix-native, so dlopen() of these bindings
  # bypasses nix-ld and hits the bare LD_LIBRARY_PATH. Forward the
  # nix-ld-managed lib path so plugin bindings resolve.
  opencodeWrapped = pkgs.symlinkJoin {
    name = "opencode-nix-ld-wrapped";
    paths = [ pkgs.opencode ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/opencode \
        --suffix LD_LIBRARY_PATH : "/run/current-system/sw/share/nix-ld/lib"
    '';
  };

in
{
  programs.opencode = {
    enable = true;
    package = opencodeWrapped;
    enableMcpIntegration = true;
    context = memoryInstructions;
    tui = {
      theme = "dracula";
    };
    inherit themes;
    settings = {
      plugin = [
        "@ex-machina/opencode-anthropic-auth@1.8.0"
        "file://${blockGitCommitsPlugin}"
        "@mohak34/opencode-notifier@0.2.4"
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
