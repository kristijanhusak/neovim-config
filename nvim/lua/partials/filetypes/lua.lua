local lua = {}
local fn = vim.fn
local utils = require('partials.utils')

local function do_print()
  local view = fn.winsaveview()
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
  vim.keymap.set('n', '<Leader>D', '<cmd>lua kris.lua.generate_docblock()<CR>', { buffer = true })
  vim.keymap.set('n', '<C-]>', ':Glance definitions<CR>', { silent = true, buffer = true })
  vim.keymap.set('n', '<leader>ll', do_print, { buffer = true })
end

function lua.generate_docblock()
  local ts_utils = require('nvim-treesitter.ts_utils')
  local node = ts_utils.get_node_at_cursor()
  if node:type() ~= 'identifier' then
    while node and node:type() ~= 'function_name' do
      node = node:parent()
    end
  end
  if not node then
    return
  end
  local param_node = ts_utils.get_next_node(node)
  if not param_node or param_node:type() ~= 'parameters' then
    return
  end
  local content = {}

  for _, child_node in ipairs(ts_utils.get_named_children(param_node)) do
    local node_text = ts_utils.get_node_text(child_node)[1]
    table.insert(content, string.format('---@param %s string', node_text))
  end

  table.insert(content, '---@return string')
  fn.append(fn.line('.') - 1, content)
end

local lua_group = vim.api.nvim_create_augroup('init_lua', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'lua',
  callback = lua.setup,
  group = lua_group,
})

_G.kris.lua = lua
