{
  pkgs,
  wrapWithAppIdentity,
  ...
}:

let
  memoryInstructions = builtins.readFile ./memory-instructions.md;
  mcpReferenceDoc = builtins.readFile ./rules/mcp-reference.md;
  gitCoauthorRule = builtins.readFile ./rules/git-coauthor.md;

  # Block git push without explicit user authorization.
  # Git commit is allowed — the App identity wrapper handles author/committer.
  blockGitPush = pkgs.writeShellScript "block-git-push" ''
    INPUT=$(cat)
    COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')
    MESSAGE=$(echo "$INPUT" | jq -r '.tool_input.message // ""')
    ALL="$COMMAND $MESSAGE"
    if echo "$ALL" | grep -qE 'git\s+push'; then
      jq -n '{
        hookSpecificOutput: {
          hookEventName: "PreToolUse",
          permissionDecision: "deny",
          permissionDecisionReason: "BLOCKED: git push requer autorização explícita do usuário."
        }
      }'
    elif echo "$ALL" | grep -q -- '--author'; then
      jq -n '{
        hookSpecificOutput: {
          hookEventName: "PreToolUse",
          permissionDecision: "deny",
          permissionDecisionReason: "BLOCKED: não use --author. A identidade PrêdaCoder[bot] é definida pelo wrapper. Use Co-authored-by no corpo do commit."
        }
      }'
    fi
  '';
in
{
  programs.claude-code = {
    enable = true;
    enableMcpIntegration = true;
    package = wrapWithAppIdentity "claude" pkgs.claude-code-bin;
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
            matcher = ".*";
            hooks = [
              {
                type = "command";
                command = "${blockGitPush}";
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
  home.file.".claude/rules/git-coauthor.md".text = gitCoauthorRule;
  home.file.".claude/agents".source = "${pkgs.gsd}/share/claude-code/agents";
  home.file.".claude/skills".source = "${pkgs.gsd}/share/claude-code/skills";
  home.file.".claude/get-shit-done".source = "${pkgs.gsd}/share/claude-code/get-shit-done";
}
