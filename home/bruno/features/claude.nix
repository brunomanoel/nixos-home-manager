{
  inputs,
  lib,
  pkgs,
  ...
}:

let
  # OpenCode Anthropic OAuth plugin (community workaround for Claude Max)
  opencodeAnthropicAuthDeps = pkgs.stdenvNoCC.mkDerivation {
    pname = "opencode-anthropic-auth-deps";
    version = "0.1.0";
    src = inputs.opencode-anthropic-auth;
    nativeBuildInputs = [ pkgs.bun ];
    buildPhase = ''
      bun install --frozen-lockfile --no-progress --ignore-scripts --no-cache
      rm -rf node_modules/.cache
    '';
    installPhase = ''
      mkdir -p $out
      cp -r node_modules $out/
    '';
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = "sha256-KuJgqiHPGvj7matYLcdLzNHLGHcRdj3A+jUBJHmRFrs=";
  };

  opencodeAnthropicAuth = pkgs.stdenvNoCC.mkDerivation {
    pname = "opencode-anthropic-auth";
    version = "0.1.0";
    src = inputs.opencode-anthropic-auth;
    nativeBuildInputs = [
      pkgs.bun
      pkgs.nodejs
    ];
    configurePhase = ''
      cp -r ${opencodeAnthropicAuthDeps}/node_modules .
      chmod -R +w node_modules
      patchShebangs node_modules
    '';
    buildPhase = ''
      bun run build
    '';
    installPhase = ''
      mkdir -p $out
      cp -r dist package.json node_modules $out/
    '';
  };

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

    **serena** — ferramentas semânticas de código. Preferir sobre Read/Edit direto:
    - `get_symbols_overview` antes de explorar arquivo novo
    - `find_symbol(name_path, include_body=true)` para ler símbolo específico
    - `find_referencing_symbols` para encontrar callers antes de refatorar
    - `replace_symbol_body` para substituir implementação completa
    - `insert_after_symbol` / `insert_before_symbol` para adicionar código
    - `find_file` / `list_dir` para navegação
    - `search_for_pattern` para regex em arquivos não-código
    - `think_about_*` para raciocinar antes de agir

    **filesystem** — operações de arquivo quando as ferramentas nativas não bastam. Root: `/home/bruno/workspaces`.

    **git** — operações git diretas: `git_status`, `git_diff_unstaged`, `git_diff_staged`, `git_add`, `git_commit`, `git_log`, `git_show`, `git_branch`, `git_checkout`, `git_create_branch`, `git_reset`.

    **github** — GitHub API. Chamar `get_me` primeiro para verificar permissões. Usar `search_*` para queries filtradas, `list_*` para listagem simples.

    **playwright** — automação de browser (servidor remoto). Usar para testes E2E e inspeção visual: `browser_navigate`, `browser_snapshot`, `browser_take_screenshot`, `browser_fill_form`, `browser_click`, `browser_evaluate`, `browser_network_requests`, `browser_console_messages`.

    **chrome-devtools** — Chrome headless local. Usar para testes visuais, performance e auditoria: `navigate_page`, `take_screenshot`, `evaluate_script`, `lighthouse_audit`, `performance_start_trace` / `stop_trace` / `analyze_insight`.
  '';

  mcpReferenceDoc = ''
    # MCP Reference — Ferramentas disponíveis

    > Fonte: `/home/bruno/dotfiles/home/bruno/features/claude.nix`
    > `context` e `context7` são EXCLUSIVAMENTE para docs de frameworks/libs/código.

    ## Ordem obrigatória para docs de frameworks/libs

    ```
    1. mcp__context__search_packages(registry, name)
    2. mcp__context__download_package(registry, name, version)
    3. mcp__context__get_docs(library, topic)
    4. mcp__context7__resolve-library-id + query-docs  ← fallback
    ```

    ## memory (`mcp__memory__*`)
    recall · remember · search_code · get_file_context · get_dependencies · find_usages · get_symbol · project_overview · forget · consolidate · stats

    ## context (`mcp__context__*`) — docs de libs
    search_packages(registry, name) · download_package(registry, name, version) · get_docs(library, topic)

    ## context7 (`mcp__context7__*`) — docs de libs (fallback)
    resolve-library-id(libraryName, query) · query-docs(libraryId, query)

    ## serena (`mcp__serena__*`)
    get_symbols_overview · find_symbol · find_referencing_symbols · replace_symbol_body · insert_after_symbol · insert_before_symbol · find_file · list_dir · search_for_pattern · think_about_collected_information · think_about_task_adherence · think_about_whether_you_are_done · read_memory · write_memory · list_memories · delete_memory · onboarding · check_onboarding_performed

    ## filesystem (`mcp__filesystem__*`)
    read_file · read_multiple_files · read_text_file · read_media_file · write_file · edit_file · list_directory · list_directory_with_sizes · directory_tree · create_directory · move_file · search_files · get_file_info · list_allowed_directories

    ## git (`mcp__git__*`)
    git_status · git_diff · git_diff_unstaged · git_diff_staged · git_add · git_commit · git_log · git_show · git_branch · git_checkout · git_create_branch · git_reset

    ## github (`mcp__github__*`)
    get_me · list_pull_requests · pull_request_read · create_pull_request · update_pull_request · merge_pull_request · pull_request_review_write · add_comment_to_pending_review · add_reply_to_pull_request_comment · list_issues · issue_read · issue_write · add_issue_comment · search_pull_requests · search_issues · search_code · get_file_contents · create_or_update_file · delete_file · push_files · list_branches · create_branch · list_commits · get_commit · list_releases · get_latest_release · get_tag · list_tags · get_label · search_repositories · search_users · fork_repository · create_repository · assign_copilot_to_issue · request_copilot_review · sub_issue_write · update_pull_request_branch

    ## fetch (`mcp__fetch__*`)
    fetch(url, method)

    ## sequential-thinking (`mcp__sequential-thinking__*`)
    sequentialthinking(thought, thoughtNumber, totalThoughts, nextThoughtNeeded)

    ## nixos (`mcp__nixos__*`)
    nix(query) · nix_versions(package)

    ## playwright (`mcp__playwright__*`)
    browser_navigate · browser_snapshot · browser_take_screenshot · browser_fill_form · browser_click · browser_type · browser_evaluate · browser_wait_for · browser_network_requests · browser_console_messages · browser_tabs · browser_navigate_back · browser_resize · browser_run_code · browser_select_option · browser_drag · browser_hover · browser_press_key · browser_file_upload · browser_handle_dialog · browser_close · browser_install

    ## chrome-devtools (`mcp__chrome-devtools__*`)
    navigate_page · take_screenshot · take_snapshot · evaluate_script · fill · fill_form · click · hover · drag · press_key · type_text · list_pages · new_page · select_page · close_page · resize_page · emulate · list_network_requests · get_network_request · list_console_messages · get_console_message · handle_dialog · upload_file · wait_for · take_memory_snapshot · performance_start_trace · performance_stop_trace · performance_analyze_insight · lighthouse_audit
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
    package = pkgs.claude-code-bin;
    memory.text = memoryInstructions;
  };

  home.file.".claude/rules/mcp-reference.md".text = mcpReferenceDoc;
  home.file.".config/opencode/rules/mcp-reference.md".text = mcpReferenceDoc;

  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;
    rules = memoryInstructions;
    tui = {
      theme = "dracula";
    };
    themes.dracula = {
      defs = {
        bgPrimary = "#282A36";
        bgSecondary = "#44475A";
        bgSelection = "#44475A";
        foreground = "#F8F8F2";
        comment = "#6272A4";
        red = "#FF5555";
        orange = "#FFB86C";
        yellow = "#F1FA8C";
        green = "#50FA7B";
        cyan = "#8BE9FD";
        purple = "#BD93F9";
        pink = "#FF79C6";
        bgDiffAdded = "#2B3A2F";
        bgDiffRemoved = "#3D2A2E";
      };
      theme = {
        primary = "purple";
        secondary = "cyan";
        accent = "pink";
        error = "red";
        warning = "orange";
        success = "green";
        info = "cyan";
        text = "foreground";
        textMuted = "comment";
        background = "bgPrimary";
        backgroundPanel = "bgSecondary";
        backgroundElement = "bgSecondary";
        border = "bgSelection";
        borderActive = "purple";
        borderSubtle = "bgSelection";
        diffAdded = "green";
        diffRemoved = "red";
        diffContext = "foreground";
        diffHunkHeader = "comment";
        diffHighlightAdded = "green";
        diffHighlightRemoved = "red";
        diffAddedBg = "bgDiffAdded";
        diffRemovedBg = "bgDiffRemoved";
        diffContextBg = "bgSecondary";
        diffLineNumber = "comment";
        diffAddedLineNumberBg = "bgDiffAdded";
        diffRemovedLineNumberBg = "bgDiffRemoved";
        markdownText = "foreground";
        markdownHeading = "purple";
        markdownLink = "cyan";
        markdownLinkText = "pink";
        markdownCode = "green";
        markdownBlockQuote = "comment";
        markdownEmph = "yellow";
        markdownStrong = "orange";
        markdownHorizontalRule = "comment";
        markdownListItem = "cyan";
        markdownListEnumeration = "purple";
        markdownImage = "pink";
        markdownImageText = "yellow";
        markdownCodeBlock = "green";
        syntaxComment = "comment";
        syntaxKeyword = "pink";
        syntaxFunction = "green";
        syntaxVariable = "foreground";
        syntaxString = "yellow";
        syntaxNumber = "purple";
        syntaxType = "cyan";
        syntaxOperator = "pink";
        syntaxPunctuation = "foreground";
      };
    };
    themes.dracula-transparent = {
      defs = {
        bgSecondary = "#44475A";
        bgSelection = "#44475A";
        foreground = "#F8F8F2";
        comment = "#6272A4";
        red = "#FF5555";
        orange = "#FFB86C";
        yellow = "#F1FA8C";
        green = "#50FA7B";
        cyan = "#8BE9FD";
        purple = "#BD93F9";
        pink = "#FF79C6";
        bgDiffAdded = "#2B3A2F";
        bgDiffRemoved = "#3D2A2E";
      };
      theme = {
        primary = "purple";
        secondary = "cyan";
        accent = "pink";
        error = "red";
        warning = "orange";
        success = "green";
        info = "cyan";
        text = "foreground";
        textMuted = "comment";
        background = "none";
        backgroundPanel = "none";
        backgroundElement = "none";
        border = "bgSelection";
        borderActive = "purple";
        borderSubtle = "bgSelection";
        diffAdded = "green";
        diffRemoved = "red";
        diffContext = "foreground";
        diffHunkHeader = "comment";
        diffHighlightAdded = "green";
        diffHighlightRemoved = "red";
        diffAddedBg = "bgDiffAdded";
        diffRemovedBg = "bgDiffRemoved";
        diffContextBg = "bgSecondary";
        diffLineNumber = "comment";
        diffAddedLineNumberBg = "bgDiffAdded";
        diffRemovedLineNumberBg = "bgDiffRemoved";
        markdownText = "foreground";
        markdownHeading = "purple";
        markdownLink = "cyan";
        markdownLinkText = "pink";
        markdownCode = "green";
        markdownBlockQuote = "comment";
        markdownEmph = "yellow";
        markdownStrong = "orange";
        markdownHorizontalRule = "comment";
        markdownListItem = "cyan";
        markdownListEnumeration = "purple";
        markdownImage = "pink";
        markdownImageText = "yellow";
        markdownCodeBlock = "green";
        syntaxComment = "comment";
        syntaxKeyword = "pink";
        syntaxFunction = "green";
        syntaxVariable = "foreground";
        syntaxString = "yellow";
        syntaxNumber = "purple";
        syntaxType = "cyan";
        syntaxOperator = "pink";
        syntaxPunctuation = "foreground";
      };
    };
    themes.catppuccin-transparent = {
      defs = {
        accent = "#b4befe";
        pink = "#f5c2e7";
        red = "#f38ba8";
        peach = "#fab387";
        yellow = "#f9e2af";
        green = "#a6e3a1";
        teal = "#94e2d5";
        sky = "#89dceb";
        blue = "#89b4fa";
        text = "#cdd6f4";
        subtext1 = "#bac2de";
        subtext0 = "#a6adc8";
        overlay2 = "#9399b2";
        surface2 = "#585b70";
        surface1 = "#45475a";
        surface0 = "#313244";
        mantle = "#181825";
      };
      theme = {
        primary = "accent";
        secondary = "accent";
        accent = "pink";
        error = "red";
        warning = "yellow";
        success = "green";
        info = "teal";
        text = "text";
        textMuted = "subtext1";
        background = "none";
        backgroundPanel = "none";
        backgroundElement = "none";
        border = "surface0";
        borderActive = "surface1";
        borderSubtle = "surface2";
        diffAdded = "green";
        diffRemoved = "red";
        diffContext = "overlay2";
        diffHunkHeader = "peach";
        diffHighlightAdded = "green";
        diffHighlightRemoved = "red";
        diffAddedBg = "#a6e3a180";
        diffRemovedBg = "#f38ba880";
        diffContextBg = "mantle";
        diffLineNumber = "surface1";
        diffAddedLineNumberBg = "#a6e3a140";
        diffRemovedLineNumberBg = "#f38ba840";
        markdownText = "text";
        markdownHeading = "accent";
        markdownLink = "blue";
        markdownLinkText = "sky";
        markdownCode = "green";
        markdownBlockQuote = "yellow";
        markdownEmph = "yellow";
        markdownStrong = "peach";
        markdownHorizontalRule = "subtext0";
        markdownListItem = "blue";
        markdownListEnumeration = "sky";
        markdownImage = "blue";
        markdownImageText = "sky";
        markdownCodeBlock = "text";
        syntaxComment = "overlay2";
        syntaxKeyword = "accent";
        syntaxFunction = "blue";
        syntaxVariable = "red";
        syntaxString = "green";
        syntaxNumber = "peach";
        syntaxType = "yellow";
        syntaxOperator = "sky";
        syntaxPunctuation = "text";
      };
    };
    themes.catppuccin-macchiato-transparent = {
      defs = {
        accent = "#b7bdf8";
        pink = "#f5bde6";
        red = "#ed8796";
        peach = "#f5a97f";
        yellow = "#eed49f";
        green = "#a6da95";
        teal = "#8bd5ca";
        sky = "#91d7e3";
        blue = "#8aadf4";
        text = "#cad3f5";
        subtext1 = "#b8c0e0";
        subtext0 = "#a5adcb";
        overlay2 = "#939ab7";
        surface2 = "#5b6078";
        surface1 = "#494d64";
        surface0 = "#363a4f";
        mantle = "#1e2030";
      };
      theme = {
        primary = "accent";
        secondary = "accent";
        accent = "pink";
        error = "red";
        warning = "yellow";
        success = "green";
        info = "teal";
        text = "text";
        textMuted = "subtext1";
        background = "none";
        backgroundPanel = "none";
        backgroundElement = "none";
        border = "surface0";
        borderActive = "surface1";
        borderSubtle = "surface2";
        diffAdded = "green";
        diffRemoved = "red";
        diffContext = "overlay2";
        diffHunkHeader = "peach";
        diffHighlightAdded = "green";
        diffHighlightRemoved = "red";
        diffAddedBg = "#a6da9580";
        diffRemovedBg = "#ed879680";
        diffContextBg = "mantle";
        diffLineNumber = "surface1";
        diffAddedLineNumberBg = "#a6da9540";
        diffRemovedLineNumberBg = "#ed879640";
        markdownText = "text";
        markdownHeading = "accent";
        markdownLink = "blue";
        markdownLinkText = "sky";
        markdownCode = "green";
        markdownBlockQuote = "yellow";
        markdownEmph = "yellow";
        markdownStrong = "peach";
        markdownHorizontalRule = "subtext0";
        markdownListItem = "blue";
        markdownListEnumeration = "sky";
        markdownImage = "blue";
        markdownImageText = "sky";
        markdownCodeBlock = "text";
        syntaxComment = "overlay2";
        syntaxKeyword = "accent";
        syntaxFunction = "blue";
        syntaxVariable = "red";
        syntaxString = "green";
        syntaxNumber = "peach";
        syntaxType = "yellow";
        syntaxOperator = "sky";
        syntaxPunctuation = "text";
      };
    };
    settings = {
      plugin = [
        "file://${opencodeAnthropicAuth}"
      ];
      permission = {
        read."~/.config/opencode/get-shit-done/*" = "allow";
        external_directory."~/.config/opencode/get-shit-done/*" = "allow";
      };
    };
  };

  # Ollama + Qdrant + Open WebUI disponíveis como CLI no Mac (serviços são NixOS-only)
  home.packages = [
    pkgs.openclaw
  ]
  ++ lib.optionals pkgs.stdenv.isDarwin (
    with pkgs;
    [
      ollama
      qdrant
      open-webui
    ]
  );
}
