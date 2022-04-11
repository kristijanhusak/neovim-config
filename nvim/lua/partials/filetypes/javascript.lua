local javascript = {}
local fn = vim.fn
local gps = require('nvim-gps')
local utils = require('partials.utils')
local ts_utils = require('nvim-treesitter.ts_utils')

function javascript.console_log()
  local view = fn.winsaveview()
  local word = fn.expand('<cword>')
  local node = ts_utils.get_node_at_cursor()
  while node and node:type() ~= 'lexical_declaration' do
    node = node:parent()
  end
  if node then
    local _, _, end_line, _ = ts_utils.get_node_range(node)
    fn.cursor(end_line + 1, 0)
  end
  local scope = utils.get_gps_scope()
  vim.cmd(
    string.format("keepjumps norm!oconsole.log('%s', %s); // eslint-disable-line no-console", scope .. word, word)
  )
  fn['repeat#set'](utils.esc('<Plug>(JsConsoleLog)'))
  fn.winrestview(view)
end

function javascript.inject_dependency()
  local view = fn.winsaveview()
  local word = fn.expand('<cword>')
  vim.api.nvim_exec([[let g:js_inject_dependency_old_reg = getreg('@z')]], false)
  vim.cmd([[silent! norm!"zyib]])
  local index_in_list = fn.index(fn.filter(fn.map(fn.split(fn.getreg('@z'), ','), 'trim(v:val)'), 'v:val !=? ""'), word)
  local move_line = ''
  if index_in_list > 0 then
    move_line = index_in_list .. 'j'
  end
  fn.search('constructor(')
  local content = 'this._' .. fn.tolower(word:sub(1, 1)) .. word:sub(2) .. ' = ' .. word .. ';'
  vim.cmd([[norm!f(%f{%]])
  local closing_bracket_line = fn.line('.')
  vim.cmd([[norm!%]])

  if index_in_list > 0 and ((fn.line('.') + index_in_list) >= closing_bracket_line) then
    move_line = ''
    fn.cursor(closing_bracket_line - 1, 0)
  end

  if move_line ~= '' then
    vim.cmd('norm!' .. move_line)
  end

  local line_content = fn.getline(fn.line('.') + 1)
  if not line_content:match(content) then
    if fn.trim(line_content) == '' then
      vim.cmd('norm!jcc' .. content)
    else
      vim.cmd('norm!o' .. content)
    end
  else
    vim.api.nvim_out_write('Already injected.\n')
  end

  fn.winrestview(view)
  vim.api.nvim_exec([[let @z = g:js_inject_dependency_old_reg]], false)
  fn['repeat#set'](utils.esc('<Plug>(JsInjectDependency)'))
end

function javascript.generate_docblock()
  local node = ts_utils.get_node_at_cursor()
  if not node then
    return
  end
  while node and node:type() ~= 'formal_parameters' do
    node = ts_utils.get_next_node(node)
  end
  if not node then
    return
  end
  local is_async = fn.getline('.'):match('^%s*async')
  local indent = fn['repeat'](' ', fn.shiftwidth())
  local content = { string.format('%s/**', indent) }

  for _, child_node in ipairs(ts_utils.get_named_children(node)) do
    local node_text = ts_utils.get_node_text(child_node)[1]
    table.insert(content, string.format('%s * @param {%s} %s', indent, node_text, node_text))
  end

  if vim.fn.expand('<cword>') ~= 'constructor' then
    table.insert(content, string.format('%s * @returns {%s}', indent, is_async and 'Promise<any>' or 'any'))
  end
  table.insert(content, string.format('%s */', indent))
  fn.append(fn.line('.') - 1, content)
end

function javascript.goto_file()
  local full_path = fn.printf('%s/%s', fn.expand('%:p:h'), fn.expand('<cfile>'))
  local stats = vim.loop.fs_stat(full_path)
  if not stats or stats.type ~= 'directory' then
    return vim.cmd([[norm! gf]])
  end

  for _, suffix in ipairs(fn.split(vim.bo.suffixesadd, ',')) do
    local index_file = full_path .. '/index' .. suffix
    if fn.filereadable(index_file) then
      return vim.cmd('edit ' .. index_file)
    end
  end
end

function javascript.generate_getter_setter()
  local word = vim.fn.input('Enter word: ', vim.fn.expand('<cword>'))
  local type = vim.fn.input('Enter type: ', 'any')
  local capitalized = word:gsub('^%l', string.upper)
  local lines = {
    '/**',
    string.format(' * @returns {%s}', type),
    ' */',
    string.format('get%s() {', capitalized),
    string.format('return this.%s;', word),
    '}',
    '',
    '/**',
    string.format(' * @param {%s} %s', type, word),
    ' */',
    string.format('set%s(%s) {', capitalized, word),
    string.format('this.%s = %s;', word, word),
    '}',
    '',
  }

  vim.fn.search([[^\s*$]])
  vim.fn.append(vim.fn.line('.'), lines)
  vim.cmd(string.format('norm!v%dj', #lines))
  vim.api.nvim_feedkeys(utils.esc('<leader>lf'), 'v', true)
end

function javascript.goto_definition()
  local params = vim.lsp.util.make_position_params()
  local line = vim.fn.line('.')
  local result = vim.lsp.buf_request_sync(0, 'textDocument/definition', params, 100)
  local client_id = nil
  if result then
    client_id = vim.tbl_keys(result)[1]
    result = vim.tbl_values(result)
  end
  if result and not vim.tbl_isempty(result) and result[1].result and not vim.tbl_isempty(result[1].result) then
    vim.lsp.handlers['textDocument/definition'](nil, result[1].result, {
      client_id = client_id,
      bufnr = 0,
      method = 'textDocument/definition',
    })
  end
  if line ~= vim.fn.line('.') then
    return
  end
  vim.cmd([[JsGotoDefinition]])
end

function javascript.indent()
  local line = vim.fn.getline(vim.v.lnum)
  local prev_line = vim.fn.getline(vim.v.lnum - 1)
  if line:match('^%s*[%*/]%s*') then
    if prev_line:match('^%s*%*%s*') then
      return vim.fn.indent(vim.v.lnum - 1)
    end
    if prev_line:match('^%s*/%*%*%s*$') then
      return vim.fn.indent(vim.v.lnum - 1) + 1
    end
  end
  return vim.fn[vim.b.old_indentexpr]()
end

vim.cmd([[nnoremap <silent><Plug>(JsConsoleLog) :<C-u>call v:lua.kris.javascript.console_log()<CR>]])
vim.cmd(
  [[nnoremap <nowait><silent><Plug>(JsInjectDependency) :<C-u>call v:lua.kris.javascript.inject_dependency()<CR>]]
)
vim.cmd(
  [[nnoremap <nowait><silent><Plug>(JsGenerateDocblock) :<C-u>call v:lua.kris.javascript.generate_docblock()<CR>]]
)
vim.cmd([[nnoremap <nowait><Plug>(JsGotoFile) :<C-u>call v:lua.kris.javascript.goto_file()<CR>]])

function javascript.setup()
  vim.keymap.set('n', '<C-]>', ':call v:lua.kris.javascript.goto_definition()<CR>', { remap = true, buffer = true })
  vim.keymap.set('x', '<C-]>', '<Plug>(JsGotoDefinition)', { remap = true, buffer = true })
  vim.keymap.set('n', '<Leader>]', '<C-W>v<Plug>(JsGotoDefinition)', { remap = true, buffer = true })
  vim.keymap.set('x', '<Leader>]', '<C-W>vgv<Plug>(JsGotoDefinition)', { remap = true, buffer = true })
  vim.keymap.set('n', '<Leader>ll', '<Plug>(JsConsoleLog)', { remap = true, buffer = true })
  vim.keymap.set('n', '<Leader>d', '<Plug>(JsInjectDependency)', { remap = true, buffer = true })
  vim.keymap.set('n', '<Leader>D', '<Plug>(JsGenerateDocblock)', { remap = true, buffer = true })
  vim.keymap.set('n', 'gf', '<Plug>(JsGotoFile)', { remap = true, buffer = true })
  vim.opt_local.isfname:append('@-@')
  local ft = vim.bo.filetype:find('javascript') and 'javascript' or 'typescript'
  vim.cmd(string.format('runtime indent/%s.vim', ft))
  vim.b.old_indentexpr = vim.bo.indentexpr:gsub('%(%)$', '')
  vim.bo.indentexpr = 'v:lua.kris.javascript.indent()'
end

local js_group = vim.api.nvim_create_augroup('custom_javascript', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
  callback = javascript.setup,
  group = js_group,
})

vim.api.nvim_create_user_command('JsGenGetSet', javascript.generate_getter_setter, { force = true })

_G.kris.javascript = javascript
