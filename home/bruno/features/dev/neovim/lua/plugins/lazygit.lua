-- lazygit.nvim: opens lazygit in a floating window, reloads buffers on changes

vim.g.lazygit_floating_window_winblend = 0
vim.g.lazygit_floating_window_scaling_factor = 0.9
vim.g.lazygit_floating_window_border_chars = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' }
vim.g.lazygit_floating_window_use_plenary = 1
vim.g.lazygit_use_neovim_remote = 1

vim.keymap.set('n', '<leader>gg', '<cmd>LazyGit<cr>', { desc = '[G]it via Lazy[G]it' })
vim.keymap.set('n', '<leader>gf', '<cmd>LazyGitFilterCurrentFile<cr>', { desc = '[G]it [F]ile history' })
