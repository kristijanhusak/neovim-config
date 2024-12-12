local utils = require('partials.utils')
local ui = {}

local function get_win_width(value_length, opts)
  return math.max(value_length + 10, (opts.prompt and opts.prompt:len() + 10 or 0))
end

---@diagnostic disable-next-line: duplicate-set-field
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
    title = ' ' .. opts.prompt,
    title_pos = 'center',
  })

  vim.api.nvim_win_set_config(winnr, { width = win_width })
  vim.api.nvim_set_current_win(winnr)
  vim.api.nvim_set_option_value('modifiable', true, { buf = bufnr })
  vim.api.nvim_set_option_value('sidescrolloff', 0, { win = winnr })
  vim.b[bufnr].disable_blink = true

  vim.keymap.set('i', '<CR>', function()
    local input = vim.trim(vim.fn.getline('.'))
    vim.api.nvim_win_close(0, true)
    vim.api.nvim_feedkeys(utils.esc('<Esc>'), 'i', true)

    return on_confirm(#input > 0 and input or nil)
  end, { buffer = bufnr })

  vim.defer_fn(function()
    vim.cmd.startinsert({ bang = true })
    vim.opt.eventignore = eventignore
  end, 10)
end

return ui
