-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.termguicolors = true
vim.g.have_nerd_font = true

-- Enable mouse (útil pra resize de splits)
vim.opt.mouse = 'a'

-- Mode já aparece na statusline
vim.opt.showmode = false

-- Save undo history
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

-- Whitespace visíveis
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Destaca linha do cursor
vim.opt.cursorline = true

-- Margem de contexto ao rolar
vim.opt.scrolloff = 10

-- Case-insensitive exceto com \C ou maiúsculas
vim.opt.ignorecase = true
vim.opt.smartcase = true
