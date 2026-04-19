-- Desabilita netrw (nvim-tree substitui)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require('nvim-tree').setup()

vim.keymap.set('n', '<leader>t', '<cmd>NvimTreeToggle<cr>', { desc = '[T]ree View' })
