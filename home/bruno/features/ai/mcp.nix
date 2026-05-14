{
  pkgs,
  ...
}:

let
  mkUvxMcp =
    name:
    pkgs.writeShellScript "mcp-${name}" ''
      unset PYTHONPATH
      exec ${pkgs.uv}/bin/uvx ${name} "$@"
    '';

  serenaMcpScript = pkgs.writeShellScript "mcp-serena" ''
    unset PYTHONPATH
    exec ${pkgs.uv}/bin/uvx --python 3.11 --from serena-agent serena start-mcp-server --context ide-assistant --project-from-cwd "$@"
  '';

  localRagScript = pkgs.writeShellScript "local-rag" ''
    PORT=4242
    while (echo >/dev/tcp/localhost/$PORT) 2>/dev/null; do
      PORT=$((PORT + 1))
    done

    CONFIG=$(mktemp /tmp/local-rag-XXXXXX.json)
    cat > "$CONFIG" << JSONEOF
    {
      "qdrant-url": "http://localhost:6333",
      "embed-provider": "ollama",
      "embed-model": "qwen3-embedding:0.6b",
      "embed-dim": 1024,
      "ollama-url": "http://localhost:11434",
      "generate-descriptions": true,
      "llm-provider": "ollama",
      "llm-model": "qwen2.5-coder:3b",
      "dashboard": true,
      "dashboard-port": $PORT
    }
    JSONEOF

    ${pkgs.nodejs_22}/bin/node ${pkgs.local-rag}/dist/bin.js serve \
      --config "$CONFIG" \
      --project-root "$PWD" \
      --project-id "$(basename "$PWD")"

    rm -f "$CONFIG"
  '';
in
{
  # Servers declarados uma vez — herdados por Claude Code e OpenCode via enableMcpIntegration
  programs.mcp = {
    enable = true;
    servers = {
      memory = {
        command = "${localRagScript}";
        args = [ ];
      };
      serena = {
        command = "${serenaMcpScript}";
        args = [ ];
      };
      context7 = {
        command = "npx";
        args = [
          "-y"
          "@upstash/context7-mcp"
        ];
      };
      filesystem = {
        command = "npx";
        args = [
          "-y"
          "@modelcontextprotocol/server-filesystem"
          "/home/bruno/workspaces"
        ];
      };
      git = {
        command = "${mkUvxMcp "mcp-server-git"}";
        args = [ ];
      };
      fetch = {
        command = "npx";
        args = [
          "-y"
          "render-fetch"
        ];
        environment = {
          PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH = "${pkgs.chromium}/bin/chromium";
        };
      };
      sequential-thinking = {
        command = "npx";
        args = [
          "-y"
          "@modelcontextprotocol/server-sequential-thinking"
        ];
      };
      nixos = {
        command = "${pkgs.mcp-nixos}/bin/mcp-nixos";
        args = [ ];
      };
      context = {
        command = "npx";
        args = [
          "-y"
          "@neuledge/context"
          "serve"
        ];
      };

      searxng = {
        command = "npx";
        args = [
          "-y"
          "mcp-searxng"
        ];
        env = {
          SEARXNG_URL = "http://searx.lab";
        };
      };

      playwright = {
        command = "npx";
        args = [
          "-y"
          "@playwright/mcp@latest"
          "--isolated"
          "--executable-path"
          "${pkgs.chromium}/bin/chromium"
        ];
      };
      chrome-devtools = {
        command = "npx";
        args = [
          "-y"
          "chrome-devtools-mcp@latest"
          "--headless"
          "--no-usage-statistics"
          "--no-performance-crux"
          "--executablePath"
          "${pkgs.chromium}/bin/chromium"
        ];
      };
    };
  };
}
