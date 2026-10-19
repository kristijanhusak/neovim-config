local colorscheme = {
  'sainnhe/everforest',
  dependencies = {
    'folke/todo-comments.nvim',
    { 'gabiuz/kape-nvim', enabled = false },
    { 'nvim-mini/mini.base16', enabled = false },
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

colorscheme.base16 = function()
  local tomorrow_night = {
    base00 = '#1d1f21',
    base01 = '#282a2e',
    base02 = '#373b41',
    base03 = '#969896',
    base04 = '#b4b7b4',
    base05 = '#c5c8c6',
    base06 = '#e0e0e0',
    base07 = '#ffffff',
    base08 = '#cc6666',
    base09 = '#de935f',
    base0A = '#f0c674',
    base0B = '#b5bd68',
    base0C = '#8abeb7',
    base0D = '#81a2be',
    base0E = '#b294bb',
    base0F = '#a3685a',
  }

  local one_night = {
    base00 = '#fafafa',
    base01 = '#f0f0f1',
    base02 = '#e5e5e6',
    base03 = '#a0a1a7',
    base04 = '#696c77',
    base05 = '#383a42',
    base06 = '#202227',
    base07 = '#090a0b',
    base08 = '#ca1243',
    base09 = '#d75f00',
    base0A = '#c18401',
    base0B = '#50a14f',
    base0C = '#0184bc',
    base0D = '#4078f2',
    base0E = '#a626a4',
    base0F = '#986801',
  }

  local bg = vim.env.NVIM_COLORSCHEME_BG or 'dark'
  local pallete = bg == 'light' and one_night or tomorrow_night

  local custom_highlights = {
    IndentLine = { link = 'IndentBlanklineChar' },
    IndentLineCurrent = { link = 'IndentBlanklineContextChar' },
    SnacksPickerPrompt = { bg = pallete.base01, fg = pallete.base0C },
    LineNr = { bg = 'NONE' },
    LineNrAbove = { bg = 'NONE' },
    LineNrBelow = { bg = 'NONE' },
    CursorLineNr = { bg = 'NONE' },
    GitSignsAdd = { bg = 'NONE' },
    GitSignsChange = { bg = 'NONE' },
    GitSignsDelete = { bg = 'NONE' },
    WinSeparator = { bg = 'NONE' },
    DiagnosticUnderlineError = { undercurl = true },
    DiagnosticUnderlineHint = { undercurl = true },
    DiagnosticUnderlineInfo = { undercurl = true },
    DiagnosticUnderlineOk = { undercurl = true },
    DiagnosticUnderlineWarn = { undercurl = true },
    WarningMsg = { fg = pallete.base0A },
    Comment = { italic = true },
    SimpleF = { fg = pallete.base08, undercurl = true, bold = true },
  }

  require('mini.base16').setup({
    palette = pallete,
    use_cterm = true,
  })

  for group, colors in pairs(custom_highlights) do
    colors.update = true
    vim.api.nvim_set_hl(0, group, colors)
  end
end

colorscheme.kape = function()
  require('kape').setup({
    styles = {
      type = {
        italic = false,
      },
    },
  })
  vim.cmd.colorscheme('kape')
  local palette = require('kape.palette.kape')

  local custom_highlights = {
    IndentLine = { fg = palette.dimmed5 },
    IndentLineCurrent = { fg = palette.text },
    NormalFloat = { bg = palette.dark1 },
    FloatBorder = { bg = palette.dark1 },
    SimpleF = { fg = palette.bright_red, undercurl = true, bold = true },
    ['@lsp.type.function'] = { link = 'Function' },
    ['@lsp.typemod.function.defaultLibrary.lua'] = { link = 'Function' },
  }

  for group, colors in pairs(custom_highlights) do
    colors.update = true
    vim.api.nvim_set_hl(0, group, colors)
  end
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
  -- if bg == 'light' then
  --   colorscheme.base16()
  -- else
  --   colorscheme.kape()
  -- end
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
