{ lib, pkgs, ... }:

{
  # MCP servers available globally across all sessions
  home.file.".claude/settings.json".text = builtins.toJSON {
    mcpServers = {
      memory = {
        type = "stdio";
        command = "npx";
        args = [
          "-y"
          "@13w/local-rag"
          "serve"
          "--config"
          ".memory.json"
        ];
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
