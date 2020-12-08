local utils = require('partials/utils')
vim.env.FZF_DEFAULT_OPTS = '--layout=reverse'
vim.g.fzf_layout = {window = { width = 0.9, height = 0.9 } }
vim.g.fzf_history_dir = '~/.local/share/fzf-history'

utils.keymap('n', '<C-p>', ':Files<CR>')
utils.keymap('n', '<Leader>b', ':Buffers<CR>')
utils.keymap('n', '<Leader>t', ':BTags<CR>')
utils.keymap('n', '<Leader>m', ':History<CR>')
utils.keymap('n', '<Leader>g', ':GFiles?<CR>')

vim.g.fzf_action = {
  ['ctrl-t'] = 'tab split',
  ['ctrl-x'] = 'split',
  ['ctrl-v'] = 'vsplit'
}

vim.api.nvim_exec([[
  function! Fzf_goto_def(lines) abort
    silent! exe 'e +BTags '.a:lines[0]
    call timer_start(10, {-> execute('startinsert') })
  endfunction

  function! Fzf_goto_line(lines) abort
    silent! exe 'e '.a:lines[0]
    call timer_start(10, {-> feedkeys(':') })
  endfunction

  let g:fzf_action['@'] = function('Fzf_goto_def')
  let g:fzf_action[':'] = function('Fzf_goto_line')
]], '')
