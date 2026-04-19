-- Entry point. Config base e setups de plugins.
-- Estrutura:
--   lua/config/*  -> options, keymaps, autocmds globais
--   lua/plugins/* -> um arquivo por plugin

require('config.options')
require('config.keymaps')
require('config.autocmds')

require('plugins.telescope')
require('plugins.nvim-tree')
require('plugins.lualine')

-- Theme
vim.cmd.colorscheme("dracula")
