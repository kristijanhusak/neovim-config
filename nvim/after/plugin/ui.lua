local utils = require('partials.utils')
local ui = {
  last_input = {},
}

local function get_win_width(value_length, opts)
  return math.max(value_length + 10, (opts.prompt and opts.prompt:len() + 10 or 0))
end

vim.ui.input = function(opts, on_confirm)
  vim.validate({
    on_confirm = { on_confirm, 'function', false },
  })
  opts = opts or {}
  local current_val = opts.default or ''
  local win_width = get_win_width(current_val:len(), opts)
  local eventignore = vim.opt.eventignore:get()
  vim.opt.eventignore:append('WinLeave')
  local bufnr, winnr = vim.lsp.util.open_floating_preview({ current_val }, '', {
    height = 1,
    border = 'rounded',
    width = win_width,
    wrap = false,
    title = opts.prompt,
    title_pos = 'center',
  })

  ui.last_input = {
    val = current_val,
    on_confirm = on_confirm,
  }
  vim.api.nvim_win_set_config(winnr, { width = win_width })
  vim.api.nvim_set_current_win(winnr)
  vim.api.nvim_set_option_value('modifiable', true, { buf = bufnr })
  vim.api.nvim_set_option_value('sidescrolloff', 0, { win = winnr })
  vim.b[bufnr].disable_blink = true

  vim.keymap.set('i', '<CR>', ui.on_input, { buffer = bufnr })
  vim.defer_fn(function()
    vim.cmd.startinsert({ bang = true })
    vim.opt.eventignore = eventignore
  end, 10)
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

return ui
