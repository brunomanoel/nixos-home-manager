vim.lsp.config('emmet_language_server', {
    cmd = { 'emmet-language-server', '--stdio' },
    filetypes = {
        'css',
        'html',
        'javascriptreact',
        'less',
        'sass',
        'scss',
        'typescriptreact',
        'vue',
    },
    root_markers = { '.git' },
})
vim.lsp.enable('emmet_language_server')
