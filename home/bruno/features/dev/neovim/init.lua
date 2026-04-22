-- Entry point. Loads base config and plugin setups.
-- Structure:
--   lua/config/*  -> global options, keymaps, autocmds
--   lua/plugins/* -> one file per plugin

require('config.options')
require('config.keymaps')
require('config.autocmds')

require('plugins.telescope')
require('plugins.nvim-tree')
require('plugins.lualine')
require('plugins.mini')
require('plugins.notify')
require('plugins.smart-splits')
require('plugins.gitsigns')
require('plugins.lazygit')
require('plugins.todo-comments')
require('plugins.blink')
require('plugins.conform')
require('plugins.tiny-inline-diagnostic')

require('lsp')

-- Theme
vim.cmd.colorscheme("dracula")

-- Transparent background (lets wezterm opacity show through).
-- Reapply on ColorScheme so theme load order doesn't matter.
local function apply_transparency()
    vim.api.nvim_set_hl(0, 'Normal', { bg = 'NONE' })
    vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'NONE' })
    -- blink.cmp uses its own highlight groups; link them to NormalFloat
    vim.api.nvim_set_hl(0, 'BlinkCmpMenu', { link = 'NormalFloat' })
    vim.api.nvim_set_hl(0, 'BlinkCmpDoc', { link = 'NormalFloat' })
    vim.api.nvim_set_hl(0, 'BlinkCmpSignatureHelp', { link = 'NormalFloat' })
end
apply_transparency()
vim.api.nvim_create_autocmd('ColorScheme', {
    pattern = '*',
    callback = apply_transparency,
})
