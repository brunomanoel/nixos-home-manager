-- smart-splits: unified navigation between nvim splits and wezterm panes
-- When hitting the nvim split edge, the key is sent to wezterm via its CLI
-- so the same key can navigate both contexts.
require('smart-splits').setup({
    multiplexer_integration = 'wezterm',
    at_edge = 'wrap',
    default_amount = 3,
})

local ss = require('smart-splits')

-- Pane/split navigation
vim.keymap.set('n', '<C-h>', ss.move_cursor_left,  { desc = 'Move to left split/pane' })
vim.keymap.set('n', '<C-j>', ss.move_cursor_down,  { desc = 'Move to lower split/pane' })
vim.keymap.set('n', '<C-k>', ss.move_cursor_up,    { desc = 'Move to upper split/pane' })
vim.keymap.set('n', '<C-l>', ss.move_cursor_right, { desc = 'Move to right split/pane' })

-- Pane/split resizing
vim.keymap.set('n', '<A-h>', ss.resize_left,  { desc = 'Resize split/pane left' })
vim.keymap.set('n', '<A-j>', ss.resize_down,  { desc = 'Resize split/pane down' })
vim.keymap.set('n', '<A-k>', ss.resize_up,    { desc = 'Resize split/pane up' })
vim.keymap.set('n', '<A-l>', ss.resize_right, { desc = 'Resize split/pane right' })
