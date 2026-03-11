{ lib, pkgs, ... }:

let
  localRagScript = pkgs.writeShellScript "local-rag" ''
    exec ${pkgs.nodejs_22}/bin/npx -y @13w/local-rag serve \
      --config ${
        builtins.toFile "memory.json" (
          builtins.toJSON {
            "qdrant-url" = "http://localhost:6333";
            "embed-provider" = "ollama";
            "embed-model" = "embeddinggemma:300m";
            "ollama-url" = "http://localhost:11434";
            "generate-descriptions" = true;
            "llm-provider" = "ollama";
            "llm-model" = "qwen2.5-coder:1.5b";
            "dashboard" = true;
            "dashboard-port" = 4242;
          }
        )
      } \
      --project-root "$PWD" \
      --project-id "$(basename "$PWD")"
  '';
in
{
  # MCP servers for Claude Code CLI
  home.file.".claude/settings.json".text = builtins.toJSON {
    mcpServers = {
      memory = {
        type = "stdio";
        command = "${localRagScript}";
        args = [ ];
      };
      context7 = {
        type = "stdio";
        command = "npx";
        args = [
          "-y"
          "@upstash/context7-mcp"
        ];
      };
    };
  };

  # MCP servers for opencode
  home.file.".config/opencode/opencode.json".text = builtins.toJSON {
    "\$schema" = "https://opencode.ai/config.json";
    permission = {
      read = {
        "~/.config/opencode/get-shit-done/*" = "allow";
      };
      external_directory = {
        "~/.config/opencode/get-shit-done/*" = "allow";
      };
    };
    mcp = {
      context7 = {
        type = "local";
        command = [
          "npx"
          "-y"
          "@upstash/context7-mcp"
        ];
      };
      memory = {
        type = "local";
        command = [ "${localRagScript}" ];
      };
    };
  };

  # Ollama + Qdrant + Open WebUI available as CLI tools on Mac (services are NixOS-only)
  home.packages = lib.mkIf pkgs.stdenv.isDarwin (
    with pkgs;
    [
      ollama
      qdrant
      open-webui
    ]
  );
}
