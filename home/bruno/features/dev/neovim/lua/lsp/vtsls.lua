vim.lsp.config('vtsls', {
    cmd = { 'vtsls', '--stdio' },
    filetypes = {
        'javascript',
        'javascriptreact',
        'javascript.jsx',
        'typescript',
        'typescriptreact',
        'typescript.tsx',
    },
    root_markers = { 'package.json', 'tsconfig.json', 'jsconfig.json', '.git' },
})
vim.lsp.enable('vtsls')
