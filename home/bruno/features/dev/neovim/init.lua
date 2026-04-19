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

-- Theme
vim.cmd.colorscheme("dracula")
