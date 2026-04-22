-- Leader
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Split/pane navigation via smart-splits.nvim (integrates with wezterm panes)

-- Keep scroll position centered
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')

-- Keep search matches centered
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')
