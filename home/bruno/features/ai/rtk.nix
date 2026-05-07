# RTK (Rust Token Killer) — CLI proxy that compresses command output before
# it reaches the LLM context. Reduces token consumption 60-90% on common
# dev commands (git, ls, grep, test runners, etc.).
#
# Integrations:
#   Claude Code — native PreToolUse hook via `rtk hook claude`
#   OpenCode   — npm plugin `opencode-rtk`
#
# Toggle: add/remove `./rtk.nix` from features/ai/default.nix imports.
{ pkgs, ... }:
{
  home.packages = [ pkgs.rtk ];

  programs.claude-code.settings.hooks.PreToolUse = [
    {
      matcher = "Bash";
      hooks = [
        {
          type = "command";
          command = "rtk hook claude";
        }
      ];
    }
  ];

  programs.opencode.settings.plugin = [ "opencode-rtk" ];
}
