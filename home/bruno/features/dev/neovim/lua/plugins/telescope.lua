local telescope = require('telescope')

telescope.setup({
    extensions = {
        ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
        },
        ['fzf'] = {},
    },
})

local builtin = require('telescope.builtin')

vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = '[F]ind [F]iles' })
vim.keymap.set('n', '<C-p>', builtin.git_files, { desc = 'Project Files' })
vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })

vim.keymap.set('n', '<leader>/', function()
    builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown({
        winblend = 10,
        previewer = false,
    }))
end, { desc = '[/] Fuzzily search in current buffer' })

vim.keymap.set('n', '<leader>s/', function()
    builtin.live_grep({
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
    })
end, { desc = '[S]earch [/] in Open Files' })
