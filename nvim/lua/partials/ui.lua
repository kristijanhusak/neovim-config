local ui = {
  last_select = {},
  last_input = {},
}
local utils = require('partials.utils')

vim.ui.select = function(items, opts, on_choice)
  vim.validate({
    items = { items, 'table', false },
    on_choice = { on_choice, 'function', false },
  })
  opts = opts or {}
  local choices = {}
  local format_item = opts.format_item or tostring
  for i, item in pairs(items) do
    table.insert(choices, string.format('%d: %s', i, format_item(item)))
  end

  kris.ui.last_select = {
    items = items,
    on_choice = on_choice,
  }

  local bufnr, winnr = vim.lsp.util.open_floating_preview(choices, '', {
    border = 'rounded',
  })
  vim.api.nvim_set_current_win(winnr)
  utils.buf_keymap(bufnr, 'n', '<CR>', '<cmd>lua kris.ui.on_select()<CR>')
end

vim.ui.input = function(opts, on_confirm)
  vim.validate({
    on_confirm = { on_confirm, 'function', false },
  })
  opts = opts or {}
  local current_val = opts.default or ''
  local bufnr, winnr = vim.lsp.util.open_floating_preview({ current_val }, '', {
    border = 'rounded',
    width = math.max(current_val:len() + 10, 30),
  })
  ui.last_input = {
    val = current_val,
    on_confirm = on_confirm,
  }
  vim.api.nvim_set_current_win(winnr)
  vim.api.nvim_buf_set_option(bufnr, 'modifiable', true)
  vim.api.nvim_win_set_option(winnr, 'sidescrolloff', 0)
  require('cmp').setup.buffer({ enabled = false })
  utils.buf_keymap(bufnr, 'i', '<CR>', '<cmd>lua kris.ui.on_input()<CR>')
  vim.defer_fn(function()
    vim.cmd([[startinsert!]])
  end, 10)
end

function ui.on_select()
  local item = ui.last_select.items[vim.fn.line('.')]
  vim.api.nvim_win_close(0, true)
  if not item then
    return ui.last_select.on_choice(nil, nil)
  end

  return ui.last_select.on_choice(item, vim.fn.line('.'))
end

function ui.on_input()
  local input = vim.trim(vim.fn.getline('.'))
  vim.api.nvim_win_close(0, true)
  vim.api.nvim_feedkeys(utils.esc('<Esc>'), 'i', true)

  if #input > 0 then
    return ui.last_input.on_confirm(input)
  end
  return ui.last_input.on_confirm(nil)
end

_G.kris.ui = ui
