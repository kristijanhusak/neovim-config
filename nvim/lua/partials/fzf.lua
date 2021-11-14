local fzf = {}
local utils = require('partials/utils')
vim.env.FZF_DEFAULT_OPTS = '--layout=reverse --bind ctrl-d:preview-down,ctrl-u:preview-up'
vim.g.fzf_layout = { window = { width = 0.8, height = 0.8 } }
vim.g.fzf_history_dir = '~/.local/share/fzf-history'

function fzf.goto_def(lines)
  vim.cmd(string.format('e +BTags %s', lines[1]))
end

function fzf.goto_line(lines)
  vim.cmd(string.format('e %s', lines[1]))
  vim.defer_fn(function()
    vim.api.nvim_feedkeys(':', 'n', false)
  end, 10)
end

utils.keymap('n', '<C-p>', ':Files<CR>')
utils.keymap('n', '<Leader>b', ':Buffers<CR>')
utils.keymap('n', '<Leader>t', ':BTags<CR>')
utils.keymap('n', '<Leader>m', ':History<CR>')
utils.keymap('n', '<Leader>g', ':GFiles?<CR>')
utils.keymap('n', '<Leader>lT', ':Tags<CR>')

vim.g.fzf_action = {
  ['ctrl-t'] = 'tab split',
  ['ctrl-x'] = 'split',
  ['ctrl-v'] = 'vsplit',
  ['@'] = fzf.goto_def,
  [':'] = fzf.goto_line,
}

_G.kris.fzf = fzf
