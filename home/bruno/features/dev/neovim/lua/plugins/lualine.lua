-- LSP clients attached to the current buffer
local function lsp_clients()
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if #clients == 0 then return '' end
    local names = {}
    for _, c in ipairs(clients) do
        table.insert(names, c.name)
    end
    return ' ' .. table.concat(names, '|')
end

require('lualine').setup({
    sections = {
        lualine_x = { lsp_clients, 'encoding', 'fileformat', 'filetype' },
    },
})
