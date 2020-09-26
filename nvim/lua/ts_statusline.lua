local ts_utils = require'nvim-treesitter.ts_utils'
local parsers = require'nvim-treesitter.parsers'

local get_line_for_node = function(node)
  local range = {node:range()}
  if range[1] == 0 then return '' end
  local line = vim.trim(vim.fn.getline(range[1] + 1))
  local no_expression = line:gsub('[%[%]%(%)%{%}%s]+', '') == ''
  if no_expression then return '' end
  return vim.trim(line:gsub('[%[%(%{]*%s*$', ''))
end

function _G.get_ts_statusline(length)
  if not parsers.has_parser() then return end

  local current_node = ts_utils.get_node_at_cursor()
  if not current_node then return "" end

  local lines = {}
  local expr = current_node:parent()
  if expr and expr:type() == 'program' then
    expr = current_node
  end
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
