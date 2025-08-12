local statusline = {
  cwd_folder = '',
  lsp_progress = '',
  clock_attached = false,
}
local statusline_group = vim.api.nvim_create_augroup('custom_statusline', { clear = true })
vim.o.statusline = '%!v:lua.require("partials.statusline").setup()'
local devicons = require('nvim-web-devicons')

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'qf',
  group = statusline_group,
  callback = function()
    vim.opt_local.statusline = '%!v:lua.require("partials.statusline").setup()'
  end
})

local c = {}

local function get_workspace_name()
  local ok, workspaces = pcall(require, 'workspaces')
  if ok then
    local name = workspaces.name()
    if name then
      return name
    end
    local all = workspaces.get()
    local cwd = vim.uv.cwd()
    local item = vim.tbl_filter(function(item)
      return item.path == cwd .. '/'
    end, all)[1]
    if item then
      return item.name
    end
  end
  return vim.fn.fnamemodify(vim.fn.getcwd(), ':t')
end

local function get_colors()
  local ok, lualine_colors = pcall(require, 'lualine.themes.' .. (vim.g.colors_name or 'none'))
  if ok then
    local convert_gui = function(color)
      if color.gui then
        local items = vim.split(color.gui, '%s+')
        vim.tbl_map(function(item)
          color[item] = true
        end, items)
        color.gui = nil
      end
      return color
    end
    c.sections = {
      modes = {
        normal = convert_gui(lualine_colors.normal.a),
        insert = convert_gui(lualine_colors.insert.a),
        command = convert_gui(lualine_colors.command.a),
        visual = convert_gui(lualine_colors.visual.a),
        replace = convert_gui(lualine_colors.visual.a),
      },
      static = convert_gui(lualine_colors.normal.b),
    }
    return
  end

  local normal_bg = vim.fn.synIDattr(vim.fn.hlID('Normal'), 'bg')
  local normal_fg = vim.fn.synIDattr(vim.fn.hlID('Normal'), 'fg')
  local comment_fg = vim.fn.synIDattr(vim.fn.hlID('Comment'), 'fg')
  c.sections = {
    modes = {
      normal = { bg = normal_fg, fg = normal_bg },
      insert = { bg = '#83a598', fg = '#3c3836' },
      command = { bg = '#8ec07c', fg = '#3c3836' },
      visual = { bg = '#fe8019', fg = '#3c3836' },
      replace = { bg = '#8ec07c', fg = '#3c3836' },
    },
    static = { fg = normal_bg, bg = comment_fg },
  }
end

function statusline.set_colors()
  get_colors()

  c.warning_fg = vim.fn.synIDattr(vim.fn.hlID('WarningMsg'), 'fg')
  c.error_fg = vim.fn.synIDattr(vim.fn.hlID('ErrorMsg'), 'fg')
  c.statusline_bg = vim.fn.synIDattr(vim.fn.hlID('Statusline'), 'bg')

  pcall(vim.api.nvim_set_hl, 0, 'StErr', { bg = c.error_fg, fg = c.sections.modes.normal.fg, bold = true })
  pcall(vim.api.nvim_set_hl, 0, 'StErrSep', { bg = c.statusline_bg, fg = c.error_fg })
  pcall(vim.api.nvim_set_hl, 0, 'StWarn', { bg = c.warning_fg, fg = c.sections.modes.normal.fg, bold = true })
  pcall(vim.api.nvim_set_hl, 0, 'StWarnSep', { bg = c.statusline_bg, fg = c.warning_fg })
  pcall(vim.api.nvim_set_hl, 0, 'StSectionASep', { bg = c.statusline_bg, fg = c.sections.modes.normal.bg })
  vim.api.nvim_set_hl(0, 'StSectionA', c.sections.modes.normal)
  pcall(vim.api.nvim_set_hl, 0, 'StSectionASep', { bg = c.statusline_bg, fg = c.sections.modes.normal.bg })
  pcall(vim.api.nvim_set_hl, 0, 'StSectionB', c.sections.static)
  pcall(vim.api.nvim_set_hl, 0, 'StSectionBSep', { bg = c.statusline_bg, fg = c.sections.static.bg })
end

local function mode_highlight(mode)
  if mode == 'i' then
    pcall(vim.api.nvim_set_hl, 0, 'StSectionA', c.sections.modes.insert)
    pcall(vim.api.nvim_set_hl, 0, 'StSectionASep', { bg = c.statusline_bg, fg = c.sections.modes.insert.bg })
  elseif mode == 'R' then
    pcall(vim.api.nvim_set_hl, 0, 'StSectionA', c.sections.modes.replace)
    pcall(vim.api.nvim_set_hl, 0, 'StSectionASep', { bg = c.statusline_bg, fg = c.sections.modes.replace.bg })
  elseif vim.tbl_contains({ 'v', 'V', '' }, mode) then
    pcall(vim.api.nvim_set_hl, 0, 'StSectionA', c.sections.modes.visual)
    pcall(vim.api.nvim_set_hl, 0, 'StSectionASep', { bg = c.statusline_bg, fg = c.sections.modes.visual.bg })
  elseif mode == 'c' then
    pcall(vim.api.nvim_set_hl, 0, 'StSectionA', c.sections.modes.command)
    pcall(vim.api.nvim_set_hl, 0, 'StSectionASep', { bg = c.statusline_bg, fg = c.sections.modes.command.bg })
  else
    pcall(vim.api.nvim_set_hl, 0, 'StSectionA', c.sections.modes.normal)
    pcall(vim.api.nvim_set_hl, 0, 'StSectionASep', { bg = c.statusline_bg, fg = c.sections.modes.normal.bg })
  end
end

statusline.set_colors()

vim.api.nvim_create_autocmd({ 'VimEnter', 'ColorScheme' }, {
  group = statusline_group,
  pattern = '*',
  callback = function()
    statusline.cwd_folder = get_workspace_name()
    statusline.set_colors()
  end,
})

vim.api.nvim_create_autocmd('DirChanged', {
  group = statusline_group,
  callback = function()
    statusline.cwd_folder = get_workspace_name()
  end,
})

local separator_types = {
  slant = {
    left_side = {
      before = '',
      after = '',
    },
    right_side = {
      before = '',
      after = '',
    },
  },
  circle = {
    left_side = {
      before = '',
      after = ' ',
    },
    right_side = {
      before = ' ',
      after = '',
    },
  },
  block = {
    left_side = {
      before = '█',
      after = '█ ',
    },
    right_side = {
      before = ' █',
      after = '█',
    },
  },
}

local separators = separator_types.slant

local function sep(item, opts, show)
  opts = opts or {}
  if show == nil then
    show = true
  end
  if not show then
    return ''
  end
  local no_after = opts.no_after or false
  local no_before = opts.no_before or false
  local sep_color = opts.sep_color
  local color = opts.color
  local side = opts.side or 'left'

  local sep_before = separators.left_side.before .. '█'
  local sep_after = '█' .. separators.left_side.after
  if side ~= 'left' then
    sep_before = separators.right_side.before .. '█'
    sep_after = '█' .. separators.right_side.after
  end

  if no_before then
    sep_before = '█'
  end

  if no_after then
    sep_after = '█'
  end

  return sep_color .. sep_before .. color .. item .. sep_color .. sep_after .. '%*'
end

local section_a = { color = '%#StSectionA#', sep_color = '%#StSectionASep#', no_before = true }
local section_a_right = vim.tbl_extend('force', section_a, { side = 'right', no_before = false })
local section_b = { color = '%#StSectionB#', sep_color = '%#StSectionBSep#' }
local section_b_right = vim.tbl_extend('keep', { side = 'right' }, section_b)
local section_warn = { color = '%#StWarn#', sep_color = '%#StWarnSep#', side = 'right', no_after = true }
local section_err = { color = '%#StErr#', sep_color = '%#StErrSep#' }
local section_err_right = vim.tbl_extend('force', section_err, { side = 'right' })

local function mode_statusline()
  local mode = vim.fn.mode()
  mode_highlight(mode)
  if vim.fn.state('o') == 'o' then
    return 'O-PENDING'
  end
  local modeMap = {
    n = 'NORMAL',
    no = 'O-PENDING',
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
  if not value then
    return value
  end
  return icon .. ' ' .. value
end

local function git_statusline()
  local result = {}
  if vim.b.gitsigns_head then
    table.insert(result, vim.b.gitsigns_head)
  elseif vim.g.gitsigns_head then
    table.insert(result, vim.g.gitsigns_head)
  end
  if vim.b.gitsigns_status then
    table.insert(result, vim.b.gitsigns_status)
  end
  if #result == 0 then
    return ''
  end
  return with_icon(table.concat(result, ' '), '')
end

local function get_path(winwidth)
  if vim.w.quickfix_title then
    return vim.w.quickfix_title
  end
  local full_path = vim.fn.expand('%:p')
  local path = full_path
  local cwd = vim.fn.getcwd()
  if path == '' then
    path = cwd
  end
  local stats = vim.loop.fs_stat(path)
  if stats and stats.type == 'directory' then
    return vim.fn.fnamemodify(path, ':~')
  end

  if full_path:sub(1, #cwd) == cwd then
    path = vim.fn.expand('%:.')
  else
    path = vim.fn.expand('%:~')
  end

  if #path < (winwidth / 1.3) then
    return path
  end

  return vim.fn.pathshorten(path)
end

function statusline.search_result()
  if vim.v.hlsearch == 0 then
    return ''
  end
  local last_search = vim.fn.getreg('/')
  if not last_search or last_search == '' then
    return ''
  end
  local ok, searchcount = pcall(vim.fn.searchcount, { maxcount = 9999 })
  if not ok then
    return 'Invalid search'
  end
  return last_search .. '(' .. searchcount.current .. '/' .. searchcount.total .. ')'
end

local function lsp_diagnostics()
  local err_count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
  local warn_count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
  local items = {}

  if err_count > 0 then
    table.insert(
      items,
      sep(' ' .. err_count, vim.tbl_extend('keep', { no_after = warn_count == 0 }, section_err_right), err_count > 0)
    )
  end

  if warn_count > 0 then
    table.insert(items, sep(' ' .. warn_count, section_warn, warn_count > 0))
  end

  return table.concat(items, '')
end

local progress = vim.defaulttable()
vim.api.nvim_create_autocmd('LspProgress', {
  ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local value = ev.data.params.value --[[@as {percentage?: number, title?: string, message?: string, kind: "begin" | "report" | "end"}]]
    if not client or type(value) ~= 'table' then
      return
    end
    local p = progress[client.id]

    for i = 1, #p + 1 do
      if i == #p + 1 or p[i].token == ev.data.params.token then
        p[i] = {
          token = ev.data.params.token,
          msg = ('[%d%%%%] %s%s'):format(
            value.kind == 'end' and 100 or value.percentage or 100,
            value.title or '',
            value.message and (' **%s**'):format(value.message) or ''
          ),
          done = value.kind == 'end',
        }
        break
      end
    end

    local msg = {} ---@type string[]
    progress[client.id] = vim.tbl_filter(function(v)
      return table.insert(msg, v.msg) or not v.done
    end, p)

    local spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }
    local icon = #progress[client.id] == 0 and ' '
      or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]

    statusline.lsp_progress = table.concat({ icon, msg[#msg] }, ' ')
    vim.api.nvim__redraw({ statusline = true })
    if #progress[client.id] == 0 then
      vim.defer_fn(function()
        statusline.lsp_progress = ''
        vim.api.nvim__redraw({ statusline = true })
      end, 500)
    end
  end,
})

local function get_modified_count()
  local bufnr = vim.api.nvim_get_current_buf()
  return #vim.tbl_filter(function(buf)
    return buf.listed
      and buf.changed
      and buf.bufnr ~= bufnr
      and vim.api.nvim_get_option_value('buftype', { buf = buf.bufnr }) == ''
  end, vim.fn.getbufinfo({ bufmodified = 1, buflisted = 1, bufloaded = 1 }))
end

local filetype_icon_cache = {}
local function filetype()
  local ft = vim.bo.filetype

  if filetype_icon_cache[ft] then
    return filetype_icon_cache[ft]
  end

  local parts = { ft }

  local ft_icon, ft_icon_hl = devicons.get_icon(vim.fn.expand('%:t'))

  if ft_icon and ft_icon ~= '' and ft_icon_hl and ft_icon_hl ~= '' then
    vim.cmd('hi ' .. ft_icon_hl .. ' guibg=' .. c.statusline_bg)
    table.insert(parts, 1, '%#' .. ft_icon_hl .. '#' .. ft_icon .. '%*')
  end

  filetype_icon_cache[ft] = ' ' .. table.concat(parts, ' ') .. ' '
  return filetype_icon_cache[ft]
end

local function clock()
  if not statusline.clock_attached then
    vim.uv.new_timer():start(
      1000,
      1000,
      vim.schedule_wrap(function()
        vim.api.nvim__redraw({ statusline = true })
      end)
    )
    statusline.clock_attached = true
  end
  return os.date('%H:%M', os.time())
end

local function statusline_active(win_id)
  local winwidth = vim.api.nvim_win_get_width(win_id)
  local mode = mode_statusline()
  local priority = {
    winwidth > 50,
    winwidth > 100,
    winwidth > 150,
    winwidth > 200,
  }
  local git_status = git_statusline()
  local search = statusline.search_result()
  local db_ui = vim.g.loaded_dbui and vim.fn['db_ui#statusline']() or ''
  local diagnostics = lsp_diagnostics()
  local modified_count = get_modified_count()
  local statusline_sections = {
    sep(mode, section_a, priority[2]),
    sep(git_status, section_b, git_status ~= '' and priority[2]),
    sep(
      get_path(winwidth),
      vim.tbl_extend('keep', vim.bo.modified and section_err or section_b, {
        no_before = not priority[2],
      })
    ),
    sep(('+%d'):format(modified_count), section_err, modified_count > 0),
    sep(' - ', section_err, not vim.bo.modifiable),
    sep('%w', section_b, vim.wo.previewwindow),
    sep('%r', section_b, vim.bo.readonly),
    sep('%q', section_b, vim.bo.buftype == 'quickfix'),
    sep(db_ui, section_b, db_ui ~= ''),
    '%=',
    sep(statusline.lsp_progress, section_b_right, statusline.lsp_progress ~= '' and priority[3]),
    sep(search, section_b_right, search ~= '' and priority[3]),
    filetype(),
    sep(' ' .. statusline.cwd_folder, section_b_right, statusline.cwd_folder ~= '' and priority[3]),
    sep(' ' .. clock(), section_a_right, priority[4]),
    sep('%4l:%-3c', vim.tbl_extend('keep', { no_after = diagnostics == '' }, section_a_right), priority[1]),
    diagnostics,
    '%<',
  }

  return table.concat(statusline_sections, '')
end

local function statusline_inactive()
  return [[ %f %m %= %y ]]
end

function statusline.setup()
  local win_id = vim.fn.win_getid()
  local focus = vim.g.statusline_winid == win_id
  if focus then
    return statusline_active(win_id)
  end
  return statusline_inactive()
end

_G.kris.get_workspace_name = get_workspace_name

return statusline
