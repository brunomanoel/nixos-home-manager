-- Treesitter: grammars provided by Nix, highlight via native API
vim.api.nvim_create_autocmd("FileType", {
    callback = function()
        pcall(vim.treesitter.start)
    end,
})

-- Highlight trailing whitespace in red (always visible)
vim.api.nvim_create_autocmd("BufWinEnter", {
    pattern = "*",
    callback = function()
        vim.fn.matchadd("ErrorMsg", [[\s\+$]])
    end,
})
