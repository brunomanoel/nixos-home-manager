-- tiny-inline-diagnostic: shows LSP diagnostics inline at end of line (Error Lens-like)
require('tiny-inline-diagnostic').setup({
    preset = 'modern',
    options = {
        show_source = { enabled = true },
        multilines = {
            enabled = true,
            always_show = false,
        },
        show_all_diags_on_cursorline = false,
        enable_on_insert = false,
        enable_on_select = false,
    },
})

-- Disable native virtual_text to avoid duplicate diagnostic messages
vim.diagnostic.config({ virtual_text = false })
