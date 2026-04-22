-- Biome LSP: only attaches in projects with biome.json (or biome.jsonc)
vim.lsp.config('biome', {
    cmd = { 'biome', 'lsp-proxy' },
    filetypes = {
        'astro',
        'css',
        'graphql',
        'javascript',
        'javascriptreact',
        'json',
        'jsonc',
        'svelte',
        'typescript',
        'typescriptreact',
        'vue',
    },
    root_markers = { 'biome.json', 'biome.jsonc' },
})
vim.lsp.enable('biome')
