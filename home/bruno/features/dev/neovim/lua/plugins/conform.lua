-- conform.nvim: formatters
require('conform').setup({
    formatters_by_ft = {
        javascript = { 'biome', 'prettierd', stop_after_first = true },
        javascriptreact = { 'biome', 'prettierd', stop_after_first = true },
        typescript = { 'biome', 'prettierd', stop_after_first = true },
        typescriptreact = { 'biome', 'prettierd', stop_after_first = true },
        json = { 'biome', 'prettierd', stop_after_first = true },
        jsonc = { 'biome', 'prettierd', stop_after_first = true },
        css = { 'biome', 'prettierd', stop_after_first = true },
        scss = { 'prettierd' },
        html = { 'prettierd' },
        yaml = { 'prettierd' },
        markdown = { 'prettierd' },
        lua = { 'stylua' },
        go = { 'gofumpt' },
        python = { 'ruff_format' },
        nix = { 'nixfmt' },
        sh = { 'shfmt' },
        bash = { 'shfmt' },
        zsh = { 'shfmt' },
    },

    format_on_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
            return nil
        end
        return { timeout_ms = 500, lsp_format = 'fallback' }
    end,
})

-- Manual format
vim.keymap.set({ 'n', 'v' }, '<leader>f', function()
    require('conform').format({ async = true, lsp_format = 'fallback' })
end, { desc = '[F]ormat buffer/selection' })

-- Toggle format-on-save (global)
vim.keymap.set('n', '<leader>uf', function()
    vim.g.disable_autoformat = not vim.g.disable_autoformat
    vim.notify('Format on save: ' .. (vim.g.disable_autoformat and 'OFF' or 'ON'))
end, { desc = 'Toggle [F]ormat on save' })
