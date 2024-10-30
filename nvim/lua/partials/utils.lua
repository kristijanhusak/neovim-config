local M = {}

function M.esc(cmd)
  return vim.api.nvim_replace_termcodes(cmd, true, false, true)
end

function M.feedkeys(key, mode)
  vim.fn.feedkeys(M.esc(key), mode or '')
end

function M.get_gps_scope(fallback)
  local gps = require('nvim-navic')
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

function M.get_visual_selection()
  local s_start = vim.fn.getpos("'<")
  local s_end = vim.fn.getpos("'>")
  local n_lines = math.abs(s_end[2] - s_start[2]) + 1
  local lines = vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)
  lines[1] = string.sub(lines[1], s_start[3], -1)
  if n_lines == 1 then
    lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3] - s_start[3] + 1)
  else
    lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3])
  end
  return table.concat(lines, '\n')
end

function M.has_words_before()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
end

function M.enable_builtin_lsp_completion()
  return vim.fn.has('nvim-0.11') > 0
end

function M.lsp_kind_icons()
  return {
    Text = '',
    Method = '󰆧',
    Function = '󰊕',
    Constructor = '',
    Field = '󰇽',
    Variable = '󰂡',
    Class = '󰠱',
    Interface = '',
    Module = '',
    Property = '󰜢',
    Unit = '',
    Value = '󰎠',
    Enum = '',
    Keyword = '󰌋',
    Snippet = '',
    Color = '󰏘',
    File = '󰈙',
    Reference = '',
    Folder = '󰉋',
    EnumMember = '',
    Constant = '󰏿',
    Struct = '',
    Event = '',
    Operator = '󰆕',
    TypeParameter = '󰅲',
  }
end

return M
