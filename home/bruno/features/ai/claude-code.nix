{
  pkgs,
  ...
}:

let
  memoryInstructions = builtins.readFile ./memory-instructions.md;
  mcpReferenceDoc = builtins.readFile ./mcp-reference.md;

  blockGitCommits = pkgs.writeShellScript "block-git-commits" ''
    COMMAND=$(jq -r '.tool_input.command')
    if echo "$COMMAND" | grep -qE 'git\s+commit' && ! echo "$COMMAND" | grep -q 'noreply@anthropic'; then
      jq -n '{
        hookSpecificOutput: {
          hookEventName: "PreToolUse",
          permissionDecision: "deny",
          permissionDecisionReason: "BLOCKED: use --author=\"Claude <noreply@anthropic.com>\""
        }
      }'
    fi
  '';
in
{
  programs.claude-code = {
    enable = true;
    enableMcpIntegration = true;
    package = pkgs.claude-code-bin;
    context = memoryInstructions;
    settings = {
      statusLine = {
        type = "command";
        command = ''node "${pkgs.gsd}/share/claude-code/hooks/gsd-statusline.js"'';
      };
      hooks = {
        SessionStart = [
          {
            hooks = [
              {
                type = "command";
                command = ''node "${pkgs.gsd}/share/claude-code/hooks/gsd-check-update.js"'';
              }
            ];
          }
          {
            hooks = [
              {
                type = "command";
                command = ''bash "${pkgs.gsd}/share/claude-code/hooks/gsd-session-state.sh"'';
              }
            ];
          }
        ];
        PostToolUse = [
          {
            matcher = "Bash|Edit|Write|MultiEdit|Agent|Task";
            hooks = [
              {
                type = "command";
                command = ''node "${pkgs.gsd}/share/claude-code/hooks/gsd-context-monitor.js"'';
                timeout = 10;
              }
            ];
          }
          {
            matcher = "Write|Edit";
            hooks = [
              {
                type = "command";
                command = ''bash "${pkgs.gsd}/share/claude-code/hooks/gsd-phase-boundary.sh"'';
                timeout = 5;
              }
            ];
          }
        ];
        PreToolUse = [
          {
            matcher = "Bash";
            hooks = [
              {
                type = "command";
                command = "${blockGitCommits}";
              }
            ];
          }
          {
            matcher = "Write|Edit";
            hooks = [
              {
                type = "command";
                command = ''node "${pkgs.gsd}/share/claude-code/hooks/gsd-prompt-guard.js"'';
                timeout = 5;
              }
            ];
          }
          {
            matcher = "Write|Edit";
            hooks = [
              {
                type = "command";
                command = ''node "${pkgs.gsd}/share/claude-code/hooks/gsd-read-guard.js"'';
                timeout = 5;
              }
            ];
          }
          {
            matcher = "Write|Edit";
            hooks = [
              {
                type = "command";
                command = ''node "${pkgs.gsd}/share/claude-code/hooks/gsd-workflow-guard.js"'';
                timeout = 5;
              }
            ];
          }
          {
            matcher = "Bash";
            hooks = [
              {
                type = "command";
                command = ''bash "${pkgs.gsd}/share/claude-code/hooks/gsd-validate-commit.sh"'';
                timeout = 5;
              }
            ];
          }
        ];
      };
    };
  };

  home.file.".claude/rules/mcp-reference.md".text = mcpReferenceDoc;
  home.file.".claude/agents".source = "${pkgs.gsd}/share/claude-code/agents";
  home.file.".claude/skills".source = "${pkgs.gsd}/share/claude-code/skills";
  home.file.".claude/get-shit-done".source = "${pkgs.gsd}/share/claude-code/get-shit-done";
}
