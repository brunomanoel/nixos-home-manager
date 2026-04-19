-- Treesitter: grammars via Nix, highlight via API nativa
vim.api.nvim_create_autocmd("FileType", {
    callback = function()
        pcall(vim.treesitter.start)
    end,
})
