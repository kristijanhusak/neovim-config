local fzf = {}
local utils = require('partials/utils')
vim.env.FZF_DEFAULT_OPTS = '--layout=reverse --bind ctrl-d:preview-down,ctrl-u:preview-up'
vim.g.fzf_layout = { window = { width = 0.8, height = 0.8 } }
vim.g.fzf_history_dir = '~/.local/share/fzf-history'

utils.keymap('n', '<C-p>', ':Files<CR>')
utils.keymap('n', '<Leader>b', ":Buffers<CR>")
utils.keymap('n', '<Leader>t', ":BTags<CR>")
utils.keymap('n', '<Leader>m', ":History<CR>")
utils.keymap('n', '<Leader>g', ":GFiles?<CR>")
utils.keymap('n', '<Leader>lT', ":Tags<CR>")

_G.kris.fzf = fzf
