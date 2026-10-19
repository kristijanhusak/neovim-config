local colorscheme = {
  'sainnhe/everforest',
  dependencies = {
    'folke/todo-comments.nvim',
  },
  priority = 1000,
}

local w = vim.uv.new_fs_event()
local kitty_colorscheme = vim.fs.normalize('~/.cache/main_colorscheme.conf')
local augroup = vim.api.nvim_create_augroup('CustomColorscheme', { clear = true })

colorscheme.watch_for_changes = function()
  if not w then
    return
  end

  w:start(
    kitty_colorscheme,
    {},
    vim.schedule_wrap(function()
      local file = vim.fn.readfile(kitty_colorscheme)
      local parts = vim.split(file[1] or '', '=')
      vim.env.NVIM_COLORSCHEME_BG = parts[2] or 'dark'
      colorscheme.set()
      vim.api.nvim_exec_autocmds('ColorScheme', { pattern = '*' })
      w:stop()
      colorscheme.watch_for_changes()
    end)
  )
end

colorscheme.everforest = function()
  vim.g.everforest_background = 'hard'
  vim.g.everforest_float_style = 'blend'
  vim.g.everforest_diagnostic_virtual_text = 'colored'
  vim.cmd.colorscheme('everforest')
  local pallete = vim.fn['everforest#get_palette']('hard', vim.empty_dict())
  vim.fn['everforest#highlight']('SimpleF', pallete.red, pallete.none, 'undercurl,bold', pallete.red)
end

colorscheme.default_palette = function()
  local palette = {}
  for name, value in pairs(vim.api.nvim_get_color_map()) do
    local color = name:match('^Nvim(.+)$')
    if color then
      palette[color] = ('#%06x'):format(value)
    end
  end
  return palette
end

colorscheme.default_highlights = function()
  local p = colorscheme.default_palette()
  local tone = vim.o.background == 'light' and 'Dark' or 'Light'
  local accents = { 'Red', 'Green', 'Yellow', 'Blue', 'Magenta', 'Cyan' }
  local terminal_colors = vim.o.background == 'light'
      and { [0] = p.DarkGrey2, [7] = p.LightGrey3, [8] = p.DarkGrey4, [15] = p.LightGrey1 }
    or { [0] = p.DarkGrey3, [7] = p.LightGrey2, [8] = p.DarkGrey4, [15] = p.LightGrey1 }

  for i, accent in ipairs(accents) do
    terminal_colors[i] = p[tone .. accent]
    terminal_colors[i + 8] = p[tone .. accent]
  end

  for i = 0, 15 do
    vim.g['terminal_color_' .. i] = terminal_colors[i]
  end

  vim.api.nvim_set_hl(0, 'SimpleF', { fg = p[tone .. 'Red'], undercurl = true, bold = true })

  -- Halfway between Normal bg and the default CursorLine bg (Grey3)
  local bg = vim.api.nvim_get_hl(0, { name = 'Normal' }).bg
  local cursorline = vim.o.background == 'light' and p.LightGrey3 or p.DarkGrey3
  local mixed = 0
  for shift = 0, 16, 8 do
    local a = bit.band(bit.rshift(bg, shift), 0xff)
    local b = bit.band(bit.rshift(tonumber(cursorline:sub(2), 16), shift), 0xff)
    mixed = mixed + bit.lshift(math.floor((a + b) / 2), shift)
  end
  vim.api.nvim_set_hl(0, 'CursorLine', { bg = mixed })
  vim.api.nvim_set_hl(0, 'CursorColumn', { bg = mixed })
  vim.api.nvim_set_hl(0, 'SnacksPickerListCursorLine', { link = 'CursorLine' })
end

colorscheme.default = function()
  vim.cmd.colorscheme('default')
end

colorscheme.set = function()
  local bg = vim.env.NVIM_COLORSCHEME_BG or 'dark'
  vim.opt.background = bg

  colorscheme.default()
  -- colorscheme.everforest()
end

colorscheme.config = function()
  require('todo-comments').setup()

  vim.cmd.filetype('plugin indent on')
  vim.cmd.syntax('on')
  vim.api.nvim_create_autocmd('ColorScheme', {
    group = augroup,
    pattern = 'default',
    callback = colorscheme.default_highlights,
  })
  colorscheme.set()
  colorscheme.watch_for_changes()
  vim.api.nvim_create_autocmd('VimLeavePre', {
    group = augroup,
    callback = function()
      if w then
        w:stop()
      end
    end,
  })
end

return colorscheme
