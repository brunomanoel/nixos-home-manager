-- Disable netrw (replaced by nvim-tree)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require('nvim-tree').setup({
    view = {
        number = false,
        relativenumber = false,
        signcolumn = 'no',
    },
})

vim.keymap.set('n', '<leader>t', '<cmd>NvimTreeToggle<cr>', { desc = '[T]ree View' })
