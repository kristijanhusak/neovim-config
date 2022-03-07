local gps = require('nvim-gps')
local M = {}

function M.esc(cmd)
  return vim.api.nvim_replace_termcodes(cmd, true, false, true)
end

function M.get_gps_scope()
  if not gps.is_available() then
    return ''
  end
  local scope = gps.get_location({ disable_icons = true }) or ''
  if scope == '' then
    return ''
  end
  scope = scope:gsub('[\'"]', ''):gsub('%s+', ' ')
  return vim.trim(scope) .. ' > '
end

_G.kris.utils = M

return M
