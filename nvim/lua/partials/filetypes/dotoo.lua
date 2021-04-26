local dotoo = {}
local utils = require'partials/utils'

vim.cmd [[augroup custom_dotoo]]
  vim.cmd [[autocmd!]]
  vim.cmd [[autocmd FileType dotoo,dotoocapture lua kris.dotoo.setup()]]
vim.cmd [[augroup END]]

function dotoo.setup()
  utils.buf_keymap(0, 'n', '<leader>o', '<cmd> lua kris.dotoo.handle_o("o")<CR>')
  utils.buf_keymap(0, 'n', '<leader>O', '<cmd> lua kris.dotoo.handle_o("O")<CR>')
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

