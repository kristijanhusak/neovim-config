local search = {}
local utils = require('partials/utils')
local is_toggle = false
local mode = 'term'
local last_search = ''

vim.cmd([[augroup init_vim_search]])
vim.cmd([[autocmd!]])
vim.cmd([[autocmd FileType qf nnoremap <silent><buffer><Leader>r :cgetexpr v:lua.kris.search.do_search()<CR>]])
vim.cmd([[autocmd FileType qf wincmd J]])
vim.cmd([[autocmd QuickFixCmdPost [^l]* nested cwindow]])
vim.cmd([[autocmd QuickFixCmdPost l* nested lwindow]])
vim.cmd([[augroup END]])

utils.keymap('n', '<Leader>f', ':call v:lua.kris.search.run("")<CR>')
utils.keymap('n', '<Leader>F', ':call v:lua.kris.search.run(expand("<cword>"))<CR>')
utils.keymap('v', '<Leader>F', ':<C-u>call v:lua.kris.search.run("", 1)<CR>')

local function cleanup(no_reset_mode)
  is_toggle = false
  if not no_reset_mode then
    mode = 'term'
  end
  return pcall(utils.unmap, 'c', '<tab>')
end

local function get_visual_selection()
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

local function msg(txt)
  return vim.api.nvim_out_write(txt .. '\n')
end

function search.toggle_search_mode()
  is_toggle = true
  mode = mode == 'regex' and 'term' or 'regex'

  return vim.fn.getcmdline()
end

function search.run(search_term, is_visual)
  local term = search_term
  if is_visual then
    term = get_visual_selection()
  end

  utils.keymap('c', '<tab>', '<C-\\>ev:lua.kris.search.toggle_search_mode()<CR><CR>', { noremap = false })

  local status, t = pcall(vim.fn.input, 'Enter ' .. mode .. ': ', term)
  if not status then
    return cleanup()
  end
  term = t

  if is_toggle then
    is_toggle = false
    return search.run(term)
  end

  cleanup('no_reset_mode')
  vim.cmd([[redraw!]])

  if term == '' then
    return msg('Empty search.')
  end

  msg('Searching for word -> ' .. term)
  local status_dir, dir = pcall(vim.fn.input, 'Path: ', '', 'file')
  if not status_dir then
    return cleanup()
  end

  local grepprg = vim.o.grepprg
  local cmd = nil
  if mode == 'term' then
    cmd = table.concat({ grepprg, '--fixed-strings', vim.fn.shellescape(term), dir }, ' ')
  else
    cmd = table.concat({ grepprg, string.format("'%s'", term), dir }, ' ')
  end

  if (not cmd or cmd == '') and last_search == '' then
    msg('Empty search.')
    return cleanup()
  end

  cmd = cmd and cmd ~= '' and cmd or last_search
  last_search = cmd

  local results = vim.fn.systemlist(cmd)
  vim.cmd([[redraw]])

  if #results <= 0 then
    msg('No results for search -> ' .. cmd)
    return cleanup()
  end

  if vim.v.shell_error and vim.v.shell_error > 0 and #results > 0 then
    msg('Search error (status: ' .. vim.v.shell_error .. '): ' .. table.concat(results, ' '))
    return cleanup()
  end

  vim.cmd([[botright cgetexpr v:lua.kris.search.do_search()]])
  return cleanup()
end

function search.do_search()
  return vim.fn.systemlist(last_search)
end

_G.kris.search = search
