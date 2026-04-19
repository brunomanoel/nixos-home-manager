-- nvim-notify: replaces vim.notify with a visual popup
local notify = require('notify')

notify.setup({
    stages = 'fade',
    timeout = 3000,
    render = 'default',
    top_down = false, -- notifications stack from the bottom up
})

vim.notify = notify

vim.keymap.set('n', '<leader>nd', notify.dismiss, { desc = '[N]otifications [D]ismiss' })
