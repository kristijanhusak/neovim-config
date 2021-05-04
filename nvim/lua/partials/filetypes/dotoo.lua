local dotoo = {}
local utils = require'partials/utils'

vim.g['dotoo#agenda#files'] = {'~/Dropbox/dotoo/**/*.org'}
vim.g['dotoo#capture#refile'] = vim.fn.expand('~/Dropbox/dotoo/refile.org')
vim.g['dotoo#capture#clock'] = 0
vim.g['dotoo_begin_src_languages'] = {'sql'}
vim.g['dotoo#agenda_views#agenda#span'] = 'week'

vim.cmd [[augroup custom_dotoo]]
  vim.cmd [[autocmd!]]
  vim.cmd [[autocmd BufNewFile,BufRead *.org setf dotoo]]
  vim.cmd [[autocmd FileType dotoo,dotoocapture lua kris.dotoo.setup()]]
  vim.cmd [[autocmd FileType dotooagenda lua kris.dotoo.setup_agenda()]]
vim.cmd [[augroup END]]

function dotoo.setup()
  utils.buf_keymap(0, 'n', '<leader>o', '<cmd> lua kris.dotoo.handle_o("o")<CR>')
  utils.buf_keymap(0, 'n', '<leader>O', '<cmd> lua kris.dotoo.handle_o("O")<CR>')
  utils.buf_keymap(0, 'n', '<S-TAB>', 'zc')
  utils.buf_keymap(0, 'i', '<C-space>', '<C-x><C-o>')
  vim.wo.foldenable = true
  vim.wo.concealcursor = 'nc'
end

function dotoo.setup_agenda()
  utils.buf_keymap(0, 'n', '<CR>', ':<C-U>call dotoo#agenda#goto_headline("pedit")<CR>')
end

function dotoo.handle_o(mapping)
  local line = vim.fn.line('.')
  local line_content = vim.fn.getline('.')
  local indent = vim.fn['repeat'](' ', vim.fn.indent(line))
  vim.cmd(string.format('norm!%s', utils.esc(mapping)))
  local newline = vim.fn.line('.')
  if line_content:match('^%s*-%s*%[.?%]') then
    vim.fn.setline(newline, string.format('%s- [ ] ', indent))
  end
  if line_content:match('^%s*-%s*%w') then
    vim.fn.setline(newline, string.format('%s- ', indent))
  end
  return vim.cmd('startinsert!')
end

_G.kris.dotoo = dotoo

