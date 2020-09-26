local ts_utils = require'nvim-treesitter.ts_utils'
local parsers = require'nvim-treesitter.parsers'

local valid_rgx = {'class', 'function', 'method'}

local get_line_for_node = function(node)
  local node_type = node:type()
  local is_valid = false
  for _, rgx in ipairs(valid_rgx) do
    if node_type:find(rgx) then
      is_valid = true
      break
    end
  end
  if not is_valid then return '' end
  local range = {node:range()}
  local line = vim.fn.getline(range[1] + 1)
  return vim.trim(line:gsub('[%[%(%{]*%s*$', ''))
end

function _G.get_ts_statusline(length)
  if not parsers.has_parser() then return end

  local current_node = ts_utils.get_node_at_cursor()
  if not current_node then return "" end

  local lines = {}
  local expr = current_node
  local prefix = " -> "

  while expr do
    local line = get_line_for_node(expr)
    if line ~= '' and not vim.tbl_contains(lines, line) then
      table.insert(lines, 1, line)
    end
    expr = expr:parent()
  end

  local text = table.concat(lines, prefix):gsub('%%', '%%%%')
  local text_len = #text
  if text_len > length then
    return '...'..text:sub(text_len - length, text_len)
  end

  return text
end
