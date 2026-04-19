-- mini.ai: treesitter-aware semantic text objects
-- af/if = around/inside function, ac/ic = class, aa/ia = argument,
-- ao/io = conditional/loop
require('mini.ai').setup({
    n_lines = 500,
    custom_textobjects = {
        f = require('mini.ai').gen_spec.treesitter({
            a = '@function.outer',
            i = '@function.inner',
        }),
        c = require('mini.ai').gen_spec.treesitter({
            a = '@class.outer',
            i = '@class.inner',
        }),
        o = require('mini.ai').gen_spec.treesitter({
            a = { '@conditional.outer', '@loop.outer' },
            i = { '@conditional.inner', '@loop.inner' },
        }),
        a = require('mini.ai').gen_spec.treesitter({
            a = '@parameter.outer',
            i = '@parameter.inner',
        }),
    },
})

-- mini.pairs: autopair () {} [] "" '' ``
require('mini.pairs').setup()

-- mini.surround: surround operations
-- sa<motion><char> = add, sd<char> = delete, sr<old><new> = replace
require('mini.surround').setup()

-- mini.bracketed: semantic motion with []
-- ]f/[f = function, ]c/[c = class, ]i/[i = indent, ]d/[d = diagnostic, etc.
require('mini.bracketed').setup()

-- mini.indentscope: vertical line showing current indentation scope
require('mini.indentscope').setup({
    symbol = '│',
    options = { try_as_border = true },
    draw = {
        animation = require('mini.indentscope').gen_animation.none(),
    },
})

-- mini.splitjoin: toggle between single-line and multiline blocks
-- gS = split/join the block under the cursor
require('mini.splitjoin').setup()
