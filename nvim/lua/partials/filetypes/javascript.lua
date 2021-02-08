local fn = vim.fn
_G.kris.javascript = {}
local utils = require'partials/utils'
local ts_utils = require'nvim-treesitter/ts_utils'

function _G.kris.javascript.console_log()
  local view = fn.winsaveview()
  local word = fn.expand('<cword>')
  local node = ts_utils.get_node_at_cursor()
  while not node or node:type() == 'lexical_declaration' do
    node = node:parent()
  end
  node = node and node:parent()
  if node then
    local _, _, end_line, _ = ts_utils.get_node_range(node)
    fn.cursor(end_line + 1, 0)
  end
  vim.cmd(string.format("keepjumps norm!oconsole.log('%s', %s); // eslint-disable-line no-console", word, word))
  fn['repeat#set'](utils.esc('<Plug>(JsConsoleLog)'))
  fn.winrestview(view)
end

function _G.kris.javascript.inject_dependency()
  local view = fn.winsaveview()
  local word = fn.expand('<cword>')
  vim.api.nvim_exec([[let g:js_inject_dependency_old_reg = getreg('@z')]], false)
  vim.cmd [[silent! norm!"zyib]]
  local index_in_list = fn.index(fn.filter(fn.map(fn.split(fn.getreg('@z'), ','), 'trim(v:val)'), 'v:val !=? ""'), word)
  local move_line = ''
  if index_in_list > 0 then
    move_line = index_in_list..'j'
  end
  fn.search('constructor(')
  local content = 'this._'..fn.tolower(word:sub(1, 1))..word:sub(2)..' = '..word..';'
  vim.cmd[[norm!f(%f{%]]
  local closing_bracket_line = fn.line('.')
  vim.cmd[[norm!%]]

  if index_in_list > 0 and ((fn.line('.') + index_in_list) >= closing_bracket_line) then
    move_line = ''
    fn.cursor(closing_bracket_line - 1, 0)
  end

  if move_line ~= '' then
    vim.cmd('norm!'..move_line)
  end

  local line_content = fn.getline(fn.line('.') + 1)
  if not line_content:match(content) then
    if fn.trim(line_content) == '' then
      vim.cmd('norm!jcc'..content)
    else
      vim.cmd('norm!o'..content)
    end
  else
    vim.api.nvim_out_write('Already injected.\n')
  end

  fn.winrestview(view)
  vim.api.nvim_exec([[let @z = g:js_inject_dependency_old_reg]], false)
  fn['repeat#set'](utils.esc('<Plug>(JsInjectDependency)'))
end

function _G.kris.javascript.generate_docblock()
  local node = ts_utils.get_node_at_cursor()
  if not node then return end
  while node and node:type() ~= 'formal_parameters' do
    node = ts_utils.get_next_node(node)
  end
  if not node then return end
  local is_async = fn.getline('.'):match('^%s*async')
  local indent = fn['repeat'](' ', fn.shiftwidth())
  local content = {string.format('%s/**', indent)}
  if is_async then
    table.insert(content, string.format('%s * @async',indent))
  end

  for _, child_node in ipairs(ts_utils.get_named_children(node)) do
    local node_text = ts_utils.get_node_text(child_node)[1]
    table.insert(content, string.format('%s * @param {%s} %s',indent, node_text, node_text))
  end

  table.insert(content, string.format('%s * @returns {%s}', indent, is_async and 'Promise<any>' or 'any'))
  table.insert(content, string.format('%s */', indent))
  fn.append(fn.line('.') - 1, content)
end

function _G.kris.javascript.goto_file()
  local full_path = fn.printf('%s/%s', fn.expand('%:p:h'), fn.expand('<cfile>'))
  local stats = vim.loop.fs_stat(full_path)
  if not stats or stats.type ~= 'directory' then
    return vim.cmd[[norm! gf]]
  end

  for _, suffix in ipairs(fn.split(vim.bo.suffixesadd, ',')) do
    local index_file = full_path..'/index'..suffix
    if fn.filereadable(index_file) then
      return vim.cmd('edit '..index_file)
    end
  end
end

vim.cmd [[nnoremap <silent><Plug>(JsConsoleLog) :<C-u>call v:lua.kris.javascript.console_log()<CR>]]
vim.cmd [[nnoremap <nowait><silent><Plug>(JsInjectDependency) :<C-u>call v:lua.kris.javascript.inject_dependency()<CR>]]
vim.cmd [[nnoremap <nowait><silent><Plug>(JsGenerateDocblock) :<C-u>call v:lua.kris.javascript.generate_docblock()<CR>]]
vim.cmd [[nnoremap <nowait><Plug>(JsGotoFile) :<C-u>call v:lua.kris.javascript.goto_file()<CR>]]

function _G.kris.javascript.setup()
  local buf = vim.api.nvim_get_current_buf()
  utils.buf_keymap(buf, 'n', '<C-]>', '<Plug>(JsGotoDefinition)', { noremap = false })
  utils.buf_keymap(buf, 'x', '<C-]>', '<Plug>(JsGotoDefinition)', { noremap = false })
  utils.buf_keymap(buf, 'n', '<Leader>]', '<C-W>v<Plug>(JsGotoDefinition)', { noremap = false })
  utils.buf_keymap(buf, 'x', '<Leader>]', '<C-W>vgv<Plug>(JsGotoDefinition)', { noremap = false })
  utils.buf_keymap(buf, 'n', '<Leader>ll', '<Plug>(JsConsoleLog)', { noremap = false })
  utils.buf_keymap(buf, 'n', '<Leader>d', '<Plug>(JsInjectDependency)', { noremap = false })
  utils.buf_keymap(buf, 'n', '<Leader>D', '<Plug>(JsGenerateDocblock)', { noremap = false })
  utils.buf_keymap(buf, 'n', 'gf', '<Plug>(JsGotoFile)', { noremap = false })
  utils.opt('o', 'isfname', vim.o.isfname..',@-@')
end

vim.cmd [[augroup javascript]]
  vim.cmd [[autocmd!]]
  vim.cmd [[autocmd FileType javascript,javascriptreact,typescript,typescriptreact call v:lua.kris.javascript.setup()]]
vim.cmd [[augroup END]]

