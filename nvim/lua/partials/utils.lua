local gps = require('nvim-navic')
local M = {}

function M.esc(cmd)
  return vim.api.nvim_replace_termcodes(cmd, true, false, true)
end

function M.get_gps_scope(fallback)
  if not gps.is_available() then
    return fallback
  end
  local scope_data = gps.get_data()
  if not scope_data or vim.tbl_isempty(scope_data) then
    return fallback
  end
  local scope_string = vim.tbl_map(function(t)
    return t.name:gsub('[\'"]', ''):gsub('%s+', ' ')
  end, scope_data)
  return table.concat(scope_string, ' > ')
end

_G.kris.utils = M

return M
