-- vscode-langservers-extracted: HTML / CSS / JSON / ESLint servers

vim.lsp.config('html', {
    cmd = { 'vscode-html-language-server', '--stdio' },
    filetypes = { 'html' },
    root_markers = { 'package.json', '.git' },
    init_options = {
        provideFormatter = false,
        embeddedLanguages = { css = true, javascript = true },
    },
})
vim.lsp.enable('html')

vim.lsp.config('cssls', {
    cmd = { 'vscode-css-language-server', '--stdio' },
    filetypes = { 'css', 'scss', 'less' },
    root_markers = { 'package.json', '.git' },
    init_options = { provideFormatter = false },
})
vim.lsp.enable('cssls')

vim.lsp.config('jsonls', {
    cmd = { 'vscode-json-language-server', '--stdio' },
    filetypes = { 'json', 'jsonc' },
    root_markers = { 'package.json', '.git' },
    init_options = { provideFormatter = false },
})
vim.lsp.enable('jsonls')

vim.lsp.config('eslint', {
    cmd = { 'vscode-eslint-language-server', '--stdio' },
    filetypes = {
        'javascript',
        'javascriptreact',
        'typescript',
        'typescriptreact',
        'vue',
        'svelte',
        'astro',
    },
    -- Don't attach when project uses Biome (biome.json takes over linting/formatting)
    root_dir = function(bufnr, on_dir)
        local biome_root = vim.fs.root(bufnr, { 'biome.json', 'biome.jsonc' })
        if biome_root then
            return -- skip eslint
        end
        local root = vim.fs.root(bufnr, {
            '.eslintrc',
            '.eslintrc.js',
            '.eslintrc.cjs',
            '.eslintrc.json',
            'eslint.config.js',
            'eslint.config.mjs',
            'eslint.config.ts',
            'package.json',
            '.git',
        })
        if root then
            on_dir(root)
        end
    end,
    -- Resolve workspaceFolder on attach: the eslint LSP requires a concrete path
    -- otherwise it throws "path argument must be of type string"
    on_new_config = function(new_config, new_root_dir)
        new_config.settings.workspaceFolder = {
            uri = vim.uri_from_fname(new_root_dir),
            name = vim.fn.fnamemodify(new_root_dir, ':t'),
        }
    end,
    settings = {
        validate = 'on',
        packageManager = nil,
        useESLintClass = false,
        experimental = { useFlatConfig = false },
        codeActionOnSave = { enable = false, mode = 'all' },
        format = false,
        quiet = false,
        onIgnoredFiles = 'off',
        rulesCustomizations = {},
        run = 'onType',
        problems = { shortenToSingleLine = false },
        nodePath = '',
        workingDirectory = { mode = 'auto' },
        codeAction = {
            disableRuleComment = {
                enable = true,
                location = 'separateLine',
            },
            showDocumentation = {
                enable = true,
            },
        },
    },
})
vim.lsp.enable('eslint')
