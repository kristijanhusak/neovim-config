local utils = require('partials/utils')

utils.keymap('n', '<F1>', '<Plug>VimspectorToggleBreakpoint', { noremap = false })
utils.keymap('n', '<F2>', '<Plug>VimspectorToggleConditionalBreakpoint', { noremap = false })
utils.keymap('n', '<F3>', '<Plug>VimspectorAddFunctionBreakpoint', { noremap = false })
utils.keymap('n', '<F4>', '<Plug>VimspectorRunToCursor', { noremap = false })
utils.keymap('n', '<F5>', '<Plug>VimspectorContinue', { noremap = false })
utils.keymap('n', '<Right>', '<Plug>VimspectorStepOver', { noremap = false })
utils.keymap('n', '<Up>', '<Plug>VimspectorStepOut', { noremap = false })
utils.keymap('n', '<Down>', '<Plug>VimspectorStepInto', { noremap = false })

vim.cmd([[command! VimspectorPause call vimspector#Pause()]])
vim.cmd([[command! VimspectorStop call vimspector#Stop()]])
