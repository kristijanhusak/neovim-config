_G.kris.git = {}
local utils = require'partials/utils'

vim.cmd [[augroup gitcommit]]
  vim.cmd [[autocmd!]]
  vim.cmd [[autocmd FileType fugitive nmap <buffer><silent> <Space> =]]
  vim.cmd [[autocmd FileType git setlocal foldenable foldmethod=syntax | nnoremap <buffer><silent> <Space> za]]
vim.cmd [[augroup END]]

vim.cmd [[command! DiffHistory call v:lua.kris.git.view_git_history()]]

local function add_mappings()
  local buf = vim.api.nvim_get_current_buf()
  utils.buf_keymap(buf, 'n', ']q', ':cnext <BAR> :call v:lua.kris.git.diff_current_quickfix_entry()<CR>')
  utils.buf_keymap(buf, 'n', '[q', ':cprevious <BAR> :call v:lua.kris.git.diff_current_quickfix_entry()<CR>')
  vim.cmd [[11copen]]
  vim.cmd [[wincmd p]]
end

function _G.kris.git.view_git_history()
  vim.cmd [[only]]
  vim.cmd [[Git difftool --name-only ! !^@]]
  _G.kris.git.diff_current_quickfix_entry()
  vim.cmd [[copen]]
  utils.buf_keymap(vim.api.nvim_get_current_buf(), 'n', '<CR>', '<CR><BAR>:call v:lua.kris.git.diff_current_quickfix_entry()<CR>')
  vim.cmd [[wincmd p]]
end

function _G.kris.git.diff_current_quickfix_entry()
  local win = vim.fn.winnr()
  for _, window in ipairs(vim.fn.getwininfo()) do
    if window.winnr ~= win and vim.fn.bufname(window.bufnr):match('^fugitive:') then
      vim.cmd('bdelete '..window.bufnr)
    end
  end
  vim.cmd [[cc]]
  add_mappings()

  local qf = vim.fn.getqflist({ context = 0, idx = 0 })
  if qf.idx and type(qf.context) == 'table' and vim.tbl_islist(qf.context.items) then
    local diff = qf.context.items[qf.idx] and qf.context.items[qf.idx].diff or {}
    for _, i in ipairs(vim.fn.reverse(vim.fn.range(#diff))) do
      vim.cmd((i > 0 and 'leftabove' or 'rightbelow')..' vert diffsplit '..vim.fn.fnameescape(diff[i + 1].filename))
      add_mappings()
    end
  end
end

