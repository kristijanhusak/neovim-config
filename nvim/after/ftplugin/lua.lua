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
  vim.keymap.set('n', '<Leader>D', lua.generate_docblock, { buffer = true })
  vim.keymap.set('n', '<leader>ll', do_print, { buffer = true })
end

function lua.generate_docblock()
  local node = vim.treesitter.get_node()
  assert(node)
  local is_method = node:type() == 'identifier' and node:parent():type() == 'method_index_expression'
  local is_parameter = node:type() == 'identifier' and node:parent():type() == 'parameters'

  if is_parameter then
    node = node:parent():prev_named_sibling():field('method')[1]
  elseif is_method then
    node = node:parent():field('method')[1]
  else
    return
  end

  local parameters_node = node:parent():next_named_sibling()
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
