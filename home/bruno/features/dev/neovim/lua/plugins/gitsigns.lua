require('gitsigns').setup({
    signs = {
        add          = { text = '▎' },
        change       = { text = '▎' },
        delete       = { text = '' },
        topdelete    = { text = '' },
        changedelete = { text = '▎' },
        untracked    = { text = '▎' },
    },
    signs_staged = {
        add          = { text = '▎' },
        change       = { text = '▎' },
        delete       = { text = '' },
        topdelete    = { text = '' },
        changedelete = { text = '▎' },
        untracked    = { text = '▎' },
    },

    current_line_blame = true,
    current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = 'eol',
        delay = 500,
        ignore_whitespace = false,
    },
    current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',

    on_attach = function(bufnr)
        local gs = require('gitsigns')

        -- Hunk navigation
        vim.keymap.set('n', ']c', function()
            if vim.wo.diff then return ']c' end
            vim.schedule(function() gs.next_hunk() end)
            return '<Ignore>'
        end, { buffer = bufnr, expr = true, desc = 'Next hunk' })

        vim.keymap.set('n', '[c', function()
            if vim.wo.diff then return '[c' end
            vim.schedule(function() gs.prev_hunk() end)
            return '<Ignore>'
        end, { buffer = bufnr, expr = true, desc = 'Prev hunk' })

        -- Hunk actions
        vim.keymap.set('n', '<leader>hs', gs.stage_hunk, { buffer = bufnr, desc = '[H]unk [S]tage' })
        vim.keymap.set('v', '<leader>hs', function() gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end, { buffer = bufnr, desc = '[H]unk [S]tage (visual)' })
        vim.keymap.set('n', '<leader>hr', gs.reset_hunk, { buffer = bufnr, desc = '[H]unk [R]eset' })
        vim.keymap.set('v', '<leader>hr', function() gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end, { buffer = bufnr, desc = '[H]unk [R]eset (visual)' })
        vim.keymap.set('n', '<leader>hS', gs.stage_buffer, { buffer = bufnr, desc = '[H]unk [S]tage buffer' })
        vim.keymap.set('n', '<leader>hR', gs.reset_buffer, { buffer = bufnr, desc = '[H]unk [R]eset buffer' })
        vim.keymap.set('n', '<leader>hp', gs.preview_hunk, { buffer = bufnr, desc = '[H]unk [P]review' })
        vim.keymap.set('n', '<leader>hb', function() gs.blame_line({ full = true }) end, { buffer = bufnr, desc = '[H]unk [B]lame line' })
        vim.keymap.set('n', '<leader>hd', gs.diffthis, { buffer = bufnr, desc = '[H]unk [D]iff this' })
        vim.keymap.set('n', '<leader>hD', function() gs.diffthis('~') end, { buffer = bufnr, desc = '[H]unk [D]iff this ~' })

        -- Toggles
        vim.keymap.set('n', '<leader>tb', gs.toggle_current_line_blame, { buffer = bufnr, desc = '[T]oggle [B]lame line' })
        vim.keymap.set('n', '<leader>td', gs.toggle_deleted, { buffer = bufnr, desc = '[T]oggle [D]eleted' })

        -- Textobject
        vim.keymap.set({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { buffer = bufnr, desc = 'Inner hunk' })
    end,
})
