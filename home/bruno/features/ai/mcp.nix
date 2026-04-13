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

  githubMcpScript = pkgs.writeShellScript "github-mcp" ''
    token=$(cat "$HOME/.config/github-mcp/token" 2>/dev/null)
    if [[ -z "$token" ]]; then
      echo "github-mcp: token not found at ~/.config/github-mcp/token" >&2
      exit 1
    fi
    export GITHUB_PERSONAL_ACCESS_TOKEN="$token"
    exec ${pkgs.github-mcp-server}/bin/github-mcp-server stdio
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
        command = "${mkUvxMcp "mcp-fetch"}";
        args = [ ];
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
      github = {
        command = "${githubMcpScript}";
        args = [ ];
      };
      playwright = {
        type = "remote";
        url = "http://10.100.0.1:8002/mcp";
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
