local M = {}

function M.keymap(mode, lhs, rhs, opts)
  return vim.api.nvim_set_keymap(
    mode,
    lhs,
    rhs,
    vim.tbl_extend('keep', opts or {}, {
      nowait = true,
      silent = true,
      noremap = true,
    })
  )
end

function M.buf_keymap(buf, mode, lhs, rhs, opts)
  return vim.api.nvim_buf_set_keymap(
    buf,
    mode,
    lhs,
    rhs,
    vim.tbl_extend('keep', opts or {}, {
      nowait = true,
      silent = true,
      noremap = true,
    })
  )
end

function M.unmap(mode, lhs)
  return vim.api.nvim_del_keymap(mode, lhs)
end

function M.esc(cmd)
  return vim.api.nvim_replace_termcodes(cmd, true, false, true)
end

function M.opt(scope, key, value)
  vim[scope][key] = value
  if scope ~= 'o' then
    vim['o'][key] = value
  end
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
