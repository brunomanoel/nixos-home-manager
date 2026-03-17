{ lib, pkgs, ... }:

let
  mkUvxMcp =
    name:
    pkgs.writeShellScript "mcp-${name}" ''
      unset PYTHONPATH
      exec ${pkgs.uv}/bin/uvx ${name} "$@"
    '';

  localRagSrc = pkgs.fetchFromGitHub {
    owner = "13W";
    repo = "local-rag";
    rev = "fb04f9191a24dec7a5d0d53431a6ef05732355d9";
    hash = "sha256-xjPWpd6kNBSs0FeD3dNeexKW1H2HjCanaPCqIZVVeYo=";
  };

  localRagPackage = pkgs.stdenv.mkDerivation (finalAttrs: {
    pname = "local-rag";
    version = "1.7.0";
    src = localRagSrc;

    nativeBuildInputs = [
      pkgs.pnpm_9
      pkgs.pnpmConfigHook
      pkgs.nodejs_22
    ];

    pnpmDeps = pkgs.fetchPnpmDeps {
      inherit (finalAttrs) pname version src;
      fetcherVersion = 1;
      hash = "sha256-ZSlJ+SsI+8K/FVz7xuIbbD74XbJUZLC4besiNo9ADUw=";
    };

    buildPhase = ''
      export HOME=$TMPDIR
      export NG_CLI_ANALYTICS=false
      pnpm build
      substituteInPlace dist/tools/recall.js \
        --replace-fail 'content.slice(0, 200)' 'content'
    '';

    dontFixup = true;

    installPhase = ''
      mkdir -p $out
      cp -r dist node_modules package.json $out/
    '';
  });

  serenaMcpScript = pkgs.writeShellScript "mcp-serena" ''
    unset PYTHONPATH
    exec ${pkgs.uv}/bin/uvx --python 3.11 --from serena-agent serena-mcp-server --context ide-assistant --project "$PWD" "$@"
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

    ${pkgs.nodejs_22}/bin/node ${localRagPackage}/dist/bin.js serve \
      --config "$CONFIG" \
      --project-root "$PWD" \
      --project-id "$(basename "$PWD")"

    rm -f "$CONFIG"
  '';

  memoryInstructions = ''
    ## Memory — regras obrigatórias

    Há um índice vetorial do codebase e das sessões anteriores (via MCP memory/local-rag),
    alimentado por Qdrant + Ollama locais. **Sempre consulte o memory antes de qualquer outra fonte.**

    ### Leitura — ordem obrigatória

    1. **memory_recall** — sempre a primeira chamada de qualquer sessão. Busca decisões,
       padrões e contexto de sessões anteriores. Não pule mesmo que a tarefa pareça simples.
    2. **memory_search_code** — para localizar funções, tipos, componentes ou qualquer
       símbolo no codebase. Usar antes de abrir qualquer arquivo.
    3. **memory_get_file_context** — para ler ao redor de um símbolo específico já localizado.
    4. **memory_get_dependencies** — antes de refatorar, para entender o grafo de imports.
    5. **memory_find_usages** — para encontrar todos os callers de uma função ou tipo.
    6. **memory_project_overview** — para orientação inicial num codebase desconhecido.

    **Só leia arquivos markdown (CLAUDE.md, CONTEXT.md, planos) se o memory não trouxer
    contexto suficiente.** Leitura de arquivo é fallback, não ponto de partida.

    ### Anti-padrões — nunca faça isso

    Estas ações são **erros**, não opções:

    - Abrir um arquivo com `Read` para localizar uma função → use `memory_search_code` primeiro
    - Usar `Bash grep` ou `mcp_grep` para encontrar onde um símbolo é usado → use `memory_find_usages`
    - Usar `Task` agent para explorar o codebase → use `memory_search_code` + `memory_get_file_context`
    - Iniciar uma sessão sem chamar `memory_recall` → sempre a primeira chamada, sem exceção
    - Ler um arquivo inteiro para entender o contexto ao redor de um símbolo → use `memory_get_file_context`
    - Acumular descobertas para registrar no final da sessão → registre com `memory_remember` imediatamente

    O índice vetorial existe, está populado e é mais rápido que qualquer busca em arquivo.
    Ignorá-lo desperdiça tokens e tempo sem nenhum benefício.

    ### Escrita — quando registrar

    Após qualquer descoberta não-óbvia, chame `memory_remember` imediatamente:
    - Decisões de arquitetura ou padrões adotados
    - Causa raiz de bugs encontrados e como foram resolvidos
    - Comportamentos não-documentados de libs ou do ambiente
    - Qualquer coisa que você teria que redescobrir se a sessão reiniciasse

    Não acumule para registrar no final — registre assim que descobrir.

    ### Limite de tamanho — regra crítica, não negociável

    O `memory_remember` **trunca silenciosamente** conteúdo longo sem aviso.
    Dados perdidos não são recuperáveis. Para garantir integridade:

    1. **Máximo 280 caracteres por memória.** Uma decisão = uma memória.
    2. **Após cada `memory_remember`, faça `memory_recall` imediato** com termo do
       final do conteúdo salvo. Se não encontrar, deletar e resalvar menor.
    3. **Nunca salvar um plano inteiro numa memória.** Quebrar em itens atômicos.
    4. **Se o usuário pedir para salvar algo grande**, avisar que será quebrado
       em partes e salvar cada parte com tags consistentes para reagrupar.

    Violação desta regra causa perda permanente de contexto entre sessões.

    ## MCPs — use automaticamente, sem precisar ser solicitado

    **context / context7** — sempre que precisar de documentação de biblioteca ou framework, siga esta ordem sem pular etapas:
    1. `context` (neuledge) — buscar no registry local
    2. Se não encontrado: usar a tool `install` do MCP context para baixar do registry da comunidade (ex: `npm/next`)
    3. Se não disponível no registry: usar a tool `add` do MCP context com a URL do repositório GitHub da biblioteca (ex: `https://github.com/vercel/next.js`) para construir o pacote localmente
    4. Último recurso: `context7` (upstash)
    Não pergunte ao usuário — siga a ordem automaticamente.

    **fetch** — sempre que precisar acessar uma URL externa (doc, repo, issue), use o MCP fetch.

    **nixos** — sempre que a pergunta envolver NixOS, Home Manager, nixpkgs ou flakes, use o MCP nixos para buscar opções e pacotes atualizados.

    **sequential-thinking** — use automaticamente em tarefas complexas de planejamento ou debugging que exigem raciocínio em múltiplos passos.
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

  programs.claude-code = {
    enable = true;
    enableMcpIntegration = true;
    memory.text = memoryInstructions;
  };

  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;
    rules = memoryInstructions;
    settings = {
      permission = {
        read."~/.config/opencode/get-shit-done/*" = "allow";
        external_directory."~/.config/opencode/get-shit-done/*" = "allow";
      };
    };
  };

  # Ollama + Qdrant + Open WebUI disponíveis como CLI no Mac (serviços são NixOS-only)
  home.packages = lib.mkIf pkgs.stdenv.isDarwin (
    with pkgs;
    [
      ollama
      qdrant
      open-webui
    ]
  );
}
