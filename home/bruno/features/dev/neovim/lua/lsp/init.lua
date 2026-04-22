-- Floating windows with rounded borders for hover, signature help and diagnostics
vim.lsp.buf.hover = (function(orig)
    return function(opts)
        opts = opts or {}
        opts.border = opts.border or 'rounded'
        return orig(opts)
    end
end)(vim.lsp.buf.hover)

vim.lsp.buf.signature_help = (function(orig)
    return function(opts)
        opts = opts or {}
        opts.border = opts.border or 'rounded'
        return orig(opts)
    end
end)(vim.lsp.buf.signature_help)

vim.diagnostic.config({
    float = { border = 'rounded' },
    virtual_text = true,
    signs = true,
    underline = true,
    severity_sort = true,
    update_in_insert = false,
})

-- Document highlight: underline instead of bg/fg color to preserve theme.
-- Reapply on ColorScheme event because themes (like dracula) set
-- LspReference* with hard-coded colors on load.
local function set_reference_highlights()
    vim.api.nvim_set_hl(0, 'LspReferenceText', { link = 'Visual' })
    vim.api.nvim_set_hl(0, 'LspReferenceRead', { link = 'Visual' })
    vim.api.nvim_set_hl(0, 'LspReferenceWrite', { link = 'Visual' })
end
set_reference_highlights()
vim.api.nvim_create_autocmd('ColorScheme', {
    pattern = '*',
    callback = set_reference_highlights,
})

-- LSP: universal keymaps + document highlight when a server attaches.
vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(event)
        local bufnr = event.buf
        local tb = require('telescope.builtin')
        local client = vim.lsp.get_client_by_id(event.data.client_id)

        -- Navigation (Telescope pickers for multi-result cases)
        vim.keymap.set('n', 'gd', tb.lsp_definitions, { buffer = bufnr, desc = '[G]o to [D]efinition' })
        vim.keymap.set('n', 'gr', tb.lsp_references, { buffer = bufnr, desc = '[G]o to [R]eferences' })
        vim.keymap.set('n', 'gi', tb.lsp_implementations, { buffer = bufnr, desc = '[G]o to [I]mplementation' })
        vim.keymap.set('n', 'gt', tb.lsp_type_definitions, { buffer = bufnr, desc = '[G]o to [T]ype definition' })

        -- Documentation
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = bufnr, desc = 'Hover documentation' })
        vim.keymap.set('i', '<C-s>', vim.lsp.buf.signature_help, { buffer = bufnr, desc = 'Signature help' })

        -- Refactor
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { buffer = bufnr, desc = '[R]e[N]ame symbol' })
        vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, { buffer = bufnr, desc = '[C]ode [A]ction' })

        -- Diagnostics
        vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { buffer = bufnr, desc = 'Open diagnostic float' })

        -- Document highlight: highlight references of the symbol under the cursor
        if client and client:supports_method('textDocument/documentHighlight') then
            local group = vim.api.nvim_create_augroup('lsp_document_highlight_' .. bufnr, { clear = true })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                group = group,
                buffer = bufnr,
                callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                group = group,
                buffer = bufnr,
                callback = vim.lsp.buf.clear_references,
            })
            vim.api.nvim_create_autocmd('LspDetach', {
                group = vim.api.nvim_create_augroup('lsp_detach_' .. bufnr, { clear = true }),
                buffer = bufnr,
                callback = function()
                    vim.lsp.buf.clear_references()
                    pcall(vim.api.nvim_del_augroup_by_name, 'lsp_document_highlight_' .. bufnr)
                end,
            })
        end
    end,
})

-- Per-server configs (each file calls vim.lsp.config + vim.lsp.enable)
require('lsp.vtsls')
require('lsp.gopls')
require('lsp.basedpyright')
require('lsp.lua_ls')
require('lsp.nixd')
require('lsp.bashls')
require('lsp.marksman')
require('lsp.docker_ls')
require('lsp.emmet')
require('lsp.vscode_langservers')
require('lsp.biome')
