_G.kris.statusline = {}
local treesitter = require'nvim-treesitter'
vim.cmd[[augroup custom_statusline]]
  vim.cmd[[ autocmd! ]]
  vim.cmd[[ autocmd BufWinEnter,WinEnter * setlocal statusline=%!v:lua.kris.statusline.setup() ]]
  vim.cmd[[ autocmd BufWinLeave,WinLeave * setlocal statusline=%f\ %y\ %m ]]
  vim.cmd[[ autocmd VimEnter,ColorScheme * call v:lua.kris.statusline.set_colors() ]]
vim.cmd[[ augroup END ]]

local c = {}

function _G.kris.statusline.set_colors()
  c.normal_bg = vim.fn.synIDattr(vim.fn.hlID('Normal'), 'bg')
  c.normal_fg = vim.fn.synIDattr(vim.fn.hlID('Normal'), 'fg')
  c.statusline_bg = vim.fn.synIDattr(vim.fn.hlID('Statusline'), 'bg')
  c.comment_fg = vim.fn.synIDattr(vim.fn.hlID('Comment'), 'fg')
  c.warning_fg = vim.fn.synIDattr(vim.fn.hlID('WarningMsg'), 'fg')
  c.error_fg = vim.fn.synIDattr(vim.fn.hlID('ErrorMsg'), 'fg')

  vim.cmd('hi StItem guibg='..c.normal_fg..' guifg='..c.normal_bg..' gui=NONE')
  vim.cmd('hi StItem2 guibg='..c.comment_fg..' guifg='..c.normal_bg..' gui=NONE')
  vim.cmd('hi StSep guifg='..c.normal_fg..' guibg='..c.statusline_bg..' gui=NONE')
  vim.cmd('hi StSep2 guifg='..c.comment_fg..' guibg='..c.statusline_bg..' gui=NONE')
  vim.cmd('hi StErr guibg='..c.error_fg..' guifg='..c.normal_bg..' gui=bold')
  vim.cmd('hi StErrSep guifg='..c.error_fg..' guibg='..c.statusline_bg..' gui=NONE')
  vim.cmd('hi StWarn guibg='..c.warning_fg..' guifg='..c.normal_bg..' gui=bold')
  vim.cmd('hi StWarnSep guifg='..c.warning_fg..' guibg='..c.statusline_bg..' gui=NONE')
end

local function sep(item, opts, show)
  opts = opts or {}
  if show == nil then
    show = true
  end
  if not show then return '' end
  local no_after = opts.no_after or false
  local no_before = opts.no_before or false
  local sep_color = opts.sep_color or '%#StSep#'
  local color = opts.color or '%#StItem#'
  local side = opts.side or 'left'

  local sep_before = '█'
  local sep_after = '█'
  if side ~= 'left' then
    sep_before = '█'
    sep_after = '█'
  end

  if no_before then
    sep_before = '█'
  end

  if no_after then
    sep_after = '█'
  end

  return sep_color..sep_before..color..item..sep_color..sep_after..'%*'
end

local st_mode = {color = '%#StMode#', sep_color = '%#StModeSep#', no_before = true }
local st_err = {color = '%#StErr#', sep_color = '%#StErrSep#'}
local st_mode_right = vim.tbl_extend('force', st_mode, { side = 'right', no_before = false })
local st_err_right = vim.tbl_extend('force', st_err, {side = 'right'})
local st_warn = {color = '%#StWarn#', sep_color = '%#StWarnSep#', side = 'right', no_after = true}
local sec_2 = {color = '%#StItem2#', sep_color = '%#StSep2#'}

local function mode_highlight(mode)
  if mode == 'i' then
    vim.cmd[[ hi StMode guibg=#83a598 guifg=#3c3836 ]]
    vim.cmd[[ hi StModeSep guifg=#83a598 ]]
  elseif vim.tbl_contains({'v', 'V', ''}, mode) then
    vim.cmd[[ hi StMode guibg=#fe8019 guifg=#3c3836 ]]
    vim.cmd[[ hi StModeSep guifg=#fe8019 ]]
  elseif mode == 'R' then
    vim.cmd[[ hi StMode guibg=#8ec07c guifg=#3c3836 ]]
    vim.cmd[[ hi StModeSep guifg=#8ec07c ]]
  else
    vim.cmd('hi StMode guibg='..c.normal_fg..' guifg='..c.normal_bg..' gui=NONE')
    vim.cmd('hi StModeSep guifg='..c.normal_fg..' guibg='..c.statusline_bg..' gui=NONE')
  end
end

local function mode_statusline()
  local mode = vim.fn.mode()
  mode_highlight(mode)
  local modeMap = {
    n = 'NORMAL',
    i = 'INSERT',
    R = 'REPLACE',
    v = 'VISUAL',
    V = 'V-LINE',
    c = 'COMMAND',
    [''] = 'V-BLOCK',
    s = 'SELECT',
    S = 'S-LINE',
    [''] = 'S-BLOCK',
    t = 'TERMINAL',
  }

  return modeMap[mode] or 'UNKNOWN'
end

local function with_icon(value, icon)
  if not value then return value end
  return icon..' '..value
end

local function git_statusline()
  local result = {}
  if vim.b.gitsigns_head then table.insert(result, vim.b.gitsigns_head) end
  if vim.b.gitsigns_status then table.insert(result, vim.b.gitsigns_status) end
  if #result == 0 then return '' end
  return with_icon(table.concat(result, ' '), '')
end

local function get_path()
  local path = vim.fn.expand('%:p')
  if path == '' then
    path = vim.fn.getcwd()
  end
  local stats = vim.loop.fs_stat(path)
  if stats and stats.type == 'directory' then
    return vim.fn.fnamemodify(path, ':~')
  end

  path = vim.fn.expand('%')

  if #path < 20 then
    return '%f'
  end

  return vim.fn.pathshorten(path)
end

local patterns = {
  '//.*$',
  '%s*[%[%(%{]*%s*$',
  '%(.*%)',
  '%s*=>%s*$',
  '^async%s*',
  '^static%s*',
  '^function%s*'
}

local function ts_statusline()
  return treesitter.statusline({
      indicator_size = 80,
      transform_fn = function(line)
        for _, p in ipairs(patterns) do line = line:gsub(p, '') end
        return line
      end
    }) or ''
end

local function ale_status(type)
  if not vim.g.loaded_ale then return '' end
  local count = vim.fn['ale#statusline#Count'](vim.api.nvim_get_current_buf())
  local errors = count.error + count.style_error
  local warnings = count.warning + count.style_warning

  if type == 'error' and errors > 0 then
    return errors..' E'
  end

  if type == 'warning' and warnings > 0 then
    return warnings..' W'
  end

  return ''
end

function _G.kris.statusline.setup()
  local mode = mode_statusline()
  local git_status = git_statusline()
  local ts_status = ts_statusline()
  local anzu = vim.fn['anzu#search_status']() or ''
  local ft = vim.bo.filetype
  local err = ale_status('error')
  local warn = ale_status('warning')
  local statusline = {
    sep(mode, st_mode),
    '%<',
    sep(git_status, sec_2, git_status ~= ''),
    sep(get_path(), vim.bo.modified and st_err or sec_2),
    sep(' + ', st_err, vim.bo.modified),
    sep(' - ', st_err, not vim.bo.modifiable),
    sep('%w', nil, vim.wo.previewwindow),
    sep('%r', nil, vim.bo.readonly),
    sep('%q', nil, vim.bo.buftype == 'quickfix'),
    sep(ts_status, sec_2, ts_status ~= ''),
    '%=',
    sep(anzu, vim.tbl_extend('keep', { side = 'right' }, sec_2), anzu ~= ''),
    sep(ft, vim.tbl_extend('keep', { side = 'right' }, sec_2), ft ~= ''),
    sep(': %c', st_mode_right),
    sep(': %l/%L', st_mode_right),
    sep('%p%%', vim.tbl_extend('keep', { no_after = err == '' and warn == '' }, st_mode_right)),
    sep(err, vim.tbl_extend('keep', { no_after = warn == '' }, st_err_right), err ~= ''),
    sep(warn, st_warn, warn ~= ''),
    '%<'
  }

  return table.concat(statusline, '')
end
