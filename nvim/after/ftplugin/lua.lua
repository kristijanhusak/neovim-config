local lua = {}
local fn = vim.fn
local utils = require('partials.utils')

local function do_print()
  local view = fn.winsaveview() or {}
  local word = fn.expand('<cword>')
  local scope = utils.get_gps_scope(word)
  if not scope:match(vim.pesc(word) .. '$') then
    scope = ('%s > %s'):format(scope, word)
  end
  vim.cmd(string.format("keepjumps norm!oprint('%s', vim.inspect(%s))", scope, word))
  fn.winrestview(view)
end

function lua.setup()
  vim.bo.keywordprg = ':help'
  vim.keymap.set('n', '<Leader>D', lua.generate_docblock, { buffer = true, desc = 'Generate docblock' })
  vim.keymap.set('n', '<leader>ll', do_print, { buffer = true, desc = 'Print word under cursor' })
end

function lua.generate_docblock()
  local node = vim.treesitter.get_node()
  assert(node)
  if node:parent():type() ~= 'parameters' then
    vim.notify('Put cursor on parameters', vim.log.levels.WARN)
    return
  end
  local parameters_node = node:parent()
  assert(parameters_node)
  local method_name = vim.treesitter.get_node_text(node, 0)

  local content = {}

  if method_name:find('^_') then
    table.insert(content, '---@private')
  end

  local return_type = 'string'

  if method_name:find('^_?is_') or method_name:find('^_?has_') then
    return_type = 'boolean'
  end

  for child in parameters_node:iter_children() do
    if child:type() == 'identifier' then
      local node_text = vim.treesitter.get_node_text(child, 0)
      table.insert(content, string.format('---@param %s string', node_text))
    end
  end

  table.insert(content, '---@return ' .. return_type)
  fn.append(fn.line('.') - 1, content)
end

lua.setup()
