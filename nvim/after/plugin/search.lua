_G.kris = _G.kris or {
  search = {},
}
local utils = require('partials.utils')
local search = {}
local is_toggle = false
local mode = 'term'
local last_search = ''

local search_group = vim.api.nvim_create_augroup('init_vim_search', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'qf',
  callback = function()
    vim.b.matchup_matchparen_enabled = 0
    vim.keymap.set('n', '<Leader>r', ':cgetexpr v:lua.kris.search.do_search()<CR>', {
      silent = true,
      buffer = true,
      desc = 'Refresh search results',
    })
    vim.cmd.wincmd('J')
  end,
  group = search_group,
})
vim.api.nvim_create_autocmd('QuickFixCmdPost', {
  pattern = '[^l]*',
  command = 'cwindow',
  nested = true,
  group = search_group,
})
vim.api.nvim_create_autocmd('QuickFixCmdPost', {
  pattern = 'l*',
  command = 'lwindow',
  nested = true,
  group = search_group,
})

vim.keymap.set('n', '<Leader>ff', ':call v:lua.kris.search.run("")<CR>', { silent = true, desc = 'Search' })
vim.keymap.set(
  'n',
  '<Leader>fw',
  ':call v:lua.kris.search.run(expand("<cword>"))<CR>',
  { silent = true, desc = 'Search for word under cursor' }
)
vim.keymap.set(
  'v',
  '<Leader>fw',
  ':<C-u>call v:lua.kris.search.run("", 1)<CR>',
  { silent = true, desc = 'Search visual selection' }
)

local function cleanup(no_reset_mode)
  is_toggle = false
  if not no_reset_mode then
    mode = 'term'
  end
  return pcall(vim.keymap.del, 'c', '<tab>')
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
    term = utils.get_visual_selection()
  end

  vim.keymap.set('c', '<tab>', '<C-\\>ev:lua.kris.search.toggle_search_mode()<CR><CR>', { remap = true })

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
  vim.cmd.redraw({ bang = true })

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
  vim.cmd.redraw()

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
return search
