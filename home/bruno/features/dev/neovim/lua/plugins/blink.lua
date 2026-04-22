-- blink.cmp: autocompletion
require('blink.cmp').setup({
    keymap = { preset = 'default' },

    appearance = {
        nerd_font_variant = 'mono',
    },

    sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
    },

    signature = {
        enabled = true,
        window = { border = 'rounded' },
    },

    completion = {
        documentation = {
            auto_show = true,
            auto_show_delay_ms = 200,
            window = { border = 'rounded' },
        },
        menu = {
            border = 'rounded',
        },
    },
})

-- Toggle docs popup on/off
vim.keymap.set('n', '<leader>ud', function()
    local cmp = require('blink.cmp.config')
    local current = cmp.completion.documentation.auto_show
    cmp.completion.documentation.auto_show = not current
    vim.notify('Completion docs: ' .. (not current and 'on' or 'off'))
end, { desc = 'Toggle completion [D]ocs popup' })
