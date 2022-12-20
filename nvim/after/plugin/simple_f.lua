local ns = vim.api.nvim_create_namespace('custom_find')

local function simple_ft(key)
  local is_forward = vim.tbl_contains({ 'f', 't' }, key)
  local col = vim.fn.col('.')
  local line = vim.fn.line('.')
  local offset = col + 1
  local chars = {}
  if is_forward then
    offset = col - 1
    chars = vim.split(vim.fn.getline(line):sub(col), '')
  else
    chars = vim.fn.reverse(vim.split(vim.fn.getline(line):sub(1, col), ''))
  end
  local chars_map = {}
  for i, char in ipairs(chars) do
    char = vim.trim(char)
    local off = is_forward and (offset + i) or (offset - i)
    if char and char ~= '' and not chars_map[char] then
      chars_map[char] = i
      vim.api.nvim_buf_add_highlight(0, ns, 'SimpleF', line - 1, off - 1, off)
    end
  end

  -- Avoid error when canceling with <C-c>
  local old_cc_keymap = vim.fn.maparg('<C-c>', 'n')
  vim.keymap.set('n', '<C-c>', '<C-c>', { buffer = true })

  vim.cmd.redraw()

  local char = vim.fn.getchar()
  vim.schedule(function()
    vim.api.nvim_buf_clear_namespace(0, ns, line - 1, line)
    if not old_cc_keymap or old_cc_keymap == '' then
      vim.keymap.del('n', '<C-c>', { buffer = true })
    else
      vim.keymap.set('n', '<C-c>', old_cc_keymap, { buffer = true })
    end
  end)
  return string.format('%s%s', key, vim.fn.nr2char(char))
end

for _, key in ipairs({ 'f', 't', 'F', 'T' }) do
  vim.keymap.set('n', key, function()
    return vim.cmd.normal({ simple_ft(key), bang = true })
  end)
  vim.keymap.set({ 'x', 'o' }, key, function()
    return simple_ft(key)
  end, { expr = true, remap = true })
end
