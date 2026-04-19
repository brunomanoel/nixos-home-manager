-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.termguicolors = true
vim.g.have_nerd_font = true

-- Enable mouse (useful for resizing splits)
vim.opt.mouse = 'a'

-- Mode already shown in the statusline
vim.opt.showmode = false

-- Save undo history
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

-- Visible whitespace characters
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Highlight the cursor line
vim.opt.cursorline = true

-- Keep context lines when scrolling
vim.opt.scrolloff = 10

-- Case-insensitive unless \C or uppercase in pattern
vim.opt.ignorecase = true
vim.opt.smartcase = true
