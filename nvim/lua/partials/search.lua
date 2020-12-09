local utils = require'partials/utils'
local is_toggle = false
local mode = 'term'
local last_search = ''

vim.cmd[[ augroup init_vim_search ]]
  vim.cmd[[ autocmd! ]]
  vim.cmd[[ autocmd FileType qf nnoremap <silent><buffer><Leader>r :call v:lua.kris.do_search('')<CR> ]]
  vim.cmd[[ autocmd QuickFixCmdPost [^l]* nested cwindow ]]
  vim.cmd[[ autocmd QuickFixCmdPost l* nested lwindow ]]
vim.cmd[[ augroup END ]]

utils.keymap('n', '<Leader>f', ':call v:lua.kris.search("")<CR>')
utils.keymap('n', '<Leader>F', ':call v:lua.kris.search(expand("<cword>"))<CR>')
utils.keymap('v', '<Leader>F', ':<C-u>call v:lua.kris.search("", 1)<CR>')

local function cleanup(no_reset_mode)
  is_toggle = false
  if not no_reset_mode then
    mode = 'term'
  end
  return vim.cmd[[ silent! cunmap <tab> ]]
end

function get_visual_selection()
  local s_start = vim.fn.getpos("'<")
  local s_end = vim.fn.getpos("'>")
  local n_lines = math.abs(s_end[2] - s_start[2]) + 1
  local lines = vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)
  lines[1] = string.sub(lines[1], s_start[3], -1)
  if n_lines == 1 then
    lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3] - s_start[3] + 1)
  else
    lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3])
  end
  return table.concat(lines, '\n')
end

function _G.kris.toggle_search_mode()
  is_toggle = true
  mode = mode == 'regex' and 'term' or 'regex'

  return vim.fn.getcmdline()
end


function _G.kris.search(search, is_visual)
  local term = search
  if is_visual then
    term = get_visual_selection()
  end

  utils.keymap('c', '<C-\\>e', 'v:lua.kris.toggle_search_mode()<CR><CR>', { noremap = false })

  vim.fn.inputsave()
  term = vim.fn.input('Enter '..mode..': ', term)

  if is_toggle then
    is_toggle = false
    return _G.kris.search(term)
  end

  cleanup('no_reset_mode')

  vim.cmd[[ redraw! ]]

  if term == '' then
    return vim.api.nvim_out_write('Empty search.')
  end

  vim.api.nvim_out_write('Searching for word -> '..term)
  local dir = vim.fn.input('Path: ', '', 'file')

  local grepprg = vim.o.grepprg
  local cmd = nil
  if mode == 'term' then
    cmd = table.concat({grepprg, '--fixed-strings', vim.fn.shellescape(term), dir}, ' ')
  else
    cmd = table.concat({grepprg, term, dir}, ' ')
  end

  return _G.kris.do_search(cmd)
end

function _G.kris.do_search(cmd)
  if (not cmd or cmd == '') and last_search == '' then
    vim.api.nvim_out_write('Empty search.\n')
    return cleanup()
  end

  cmd = cmd and cmd ~= '' and cmd or last_search
  last_search = cmd

  local results = vim.fn.systemlist(cmd)

  if #results <= 0 then
    vim.api.nvim_out_write('No results for search -> '..cmd..'\n')
    return cleanup()
  end

  if vim.v.shell_error and vim.v.shell_error > 0 and #results > 0 then
    vim.api.nvim_out_write('Search error (status: '..vim.v.shell_error..'): '..table.concat(results, ' ')..'\n')
    return cleanup()
  end

  vim.cmd("cgetexpr "..table.concat(results, '\n'))
  return cleanup()
end
