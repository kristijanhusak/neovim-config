local M = {}

function M.esc(cmd)
  return vim.api.nvim_replace_termcodes(cmd, true, false, true)
end

local patterns = {
  '//.*$',
  '%s*[%[%(%{]*%s*$',
  '%(.*%)',
  '%s*=>%s*$',
  '^async%s*',
  '^static%s*',
  '^function%s*',
  '^class%s*',
  '%s*extends.*$',
}
function M.cleanup_ts_node(line)
  for _, p in ipairs(patterns) do
    line = line:gsub(p, '')
  end
  return line
end

_G.kris.utils = M

return M
