local M = {}

function M.esc(cmd)
  return vim.api.nvim_replace_termcodes(cmd, true, false, true)
end

_G.kris.utils = M

return M
