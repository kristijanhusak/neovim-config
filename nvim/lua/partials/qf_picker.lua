-- Prototype: quickfix list as a picker. Same interface as SnacksPicker in picker.lua.
-- While open: type to filter, <C-n>/<C-j>/<Down> and <C-p>/<C-k>/<Up> to move, <CR> to select, <Esc>/<C-c> to cancel.
local MAX_RESULTS = 500
local KEYS = {
  bs = vim.keycode('<BS>'),
  del = vim.keycode('<Del>'),
  cr = vim.keycode('<CR>'),
  esc = vim.keycode('<Esc>'),
  c_c = vim.keycode('<C-c>'),
  c_u = vim.keycode('<C-u>'),
  c_w = vim.keycode('<C-w>'),
  c_n = vim.keycode('<C-n>'),
  c_p = vim.keycode('<C-p>'),
  c_j = vim.keycode('<C-j>'),
  c_k = vim.keycode('<C-k>'),
  down = vim.keycode('<Down>'),
  up = vim.keycode('<Up>'),
}

local last

function _G.QFPickerTextFunc(info)
  local items = vim.fn.getqflist({ id = info.id, items = 1 }).items
  local lines = {}
  for i = info.start_idx, info.end_idx do
    lines[#lines + 1] = items[i].text
  end
  return lines
end

local function relpath(path)
  return vim.fn.fnamemodify(path, ':~:.')
end

local function open_item(item)
  if not item.file then
    return
  end
  vim.cmd.edit(vim.fn.fnameescape(item.file))
  if item.lnum then
    pcall(vim.api.nvim_win_set_cursor, 0, { item.lnum, math.max((item.col or 1) - 1, 0) })
  end
end

local MAX_PREVIEW_SIZE = 2 * 1024 * 1024
local preview_ns = vim.api.nvim_create_namespace('qf_picker_preview')

--- Float above the quickfix window that shows the selected item's file.
local function new_preview(qf_win)
  local row = vim.api.nvim_win_get_position(qf_win)[1]
  if row < 5 then
    return nil
  end
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = 'wipe'
  local win = vim.api.nvim_open_win(buf, false, {
    relative = 'editor',
    row = 0,
    col = 0,
    width = vim.o.columns - 2,
    height = row - 3,
    style = 'minimal',
    border = 'rounded',
    focusable = false,
    noautocmd = true,
  })
  vim.wo[win].number = true
  vim.wo[win].wrap = false
  vim.wo[win].winhighlight = 'NormalFloat:Normal'

  local preview = { win = win, buf = buf }

  function preview.show(item)
    if not vim.api.nvim_win_is_valid(win) then
      return
    end
    local file = item and item.file
    local key = item and item.preview and (item.text .. '\0' .. file) or file
    if key ~= preview.key then
      preview.key = key
      local lines, ft
      if item and item.preview then
        lines, ft = item.preview()
      elseif not file then
        lines = {}
      elseif (vim.uv.fs_stat(file) or {}).type ~= 'file' then
        lines = { '(not a file)' }
      elseif vim.uv.fs_stat(file).size > MAX_PREVIEW_SIZE then
        lines = { '(file too large)' }
      else
        lines = vim.fn.readfile(file, '', math.max(300, (item.lnum or 0) + 150))
        ft = vim.filetype.match({ filename = file, contents = lines })
      end
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
      vim.bo[buf].syntax = ''
      pcall(vim.treesitter.stop, buf)
      local lang = ft and vim.treesitter.language.get_lang(ft)
      if not (lang and pcall(vim.treesitter.start, buf, lang)) and ft then
        vim.bo[buf].syntax = ft
      end
    end
    vim.api.nvim_buf_clear_namespace(buf, preview_ns, 0, -1)
    local lnum = math.min(item and item.lnum or 1, math.max(vim.api.nvim_buf_line_count(buf), 1))
    if item and item.lnum then
      vim.api.nvim_buf_set_extmark(buf, preview_ns, lnum - 1, 0, { line_hl_group = 'CursorLine' })
    end
    vim.api.nvim_win_set_cursor(win, { lnum, 0 })
    vim.api.nvim_win_call(win, function()
      vim.cmd('normal! zz')
    end)
  end

  function preview.close()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end

  return preview
end

--- Core engine.
---@param opts { title: string, items?: table[], live?: fun(query: string): table[], query?: string,
---   on_select?: fun(item: table, query: string), on_empty?: fun(query: string) }
--- Items are `{ text = string, file?, lnum?, col?, ... }`. `text` is what is shown and fuzzy matched.
--- With `live`, the function is called on every query change instead of filtering `items`.
local function pick(opts)
  local query = opts.query or ''
  local origin_win = vim.api.nvim_get_current_win()
  local had_list = vim.fn.getqflist({ nr = '$' }).nr > 0
  local selected = 1
  local current = {}
  local first = true
  local preview

  -- The cursor would otherwise blink in the window behind the preview while we wait for keys.
  local guicursor = vim.o.guicursor
  vim.api.nvim_set_hl(0, 'QFPickerHiddenCursor', { blend = 100, nocombine = true })
  vim.o.guicursor = 'a:QFPickerHiddenCursor'

  local texts, by_text
  if opts.items then
    texts, by_text = {}, {}
    for _, item in ipairs(opts.items) do
      if by_text[item.text] == nil then
        texts[#texts + 1] = item.text
        by_text[item.text] = item
      end
    end
  end

  local function matches()
    if opts.live then
      return opts.live(query)
    elseif query == '' then
      return opts.items
    end
    return vim.tbl_map(function(text)
      return by_text[text]
    end, vim.fn.matchfuzzy(texts, query))
  end

  local function render()
    local found = matches()
    current = vim.list_slice(found, 1, MAX_RESULTS)
    local count = opts.live and ('%d'):format(#found) or ('%d/%d'):format(#found, #texts)
    -- Plain text items on purpose: items with a `filename` make Neovim create a buffer for each of them.
    vim.fn.setqflist({}, first and ' ' or 'r', {
      items = vim.tbl_map(function(item)
        return { text = item.text }
      end, current),
      title = ('%s (%s)'):format(opts.title, count),
      quickfixtextfunc = 'v:lua.QFPickerTextFunc',
    })
    if first then
      vim.cmd('botright copen 15')
      first = false
      preview = new_preview(vim.fn.getqflist({ winid = 0 }).winid)
    end
    selected = math.max(1, math.min(selected, #current))
    local qf_win = vim.fn.getqflist({ winid = 0 }).winid
    if qf_win ~= 0 and #current > 0 then
      vim.api.nvim_win_set_cursor(qf_win, { selected, 0 })
    end
    if preview then
      preview.show(current[selected])
    end
    vim.cmd('redraw')
    vim.api.nvim_echo({ { '> ', 'Question' }, { query } }, false, {})
  end

  local function close()
    last = { opts = opts, query = query }
    vim.o.guicursor = guicursor
    if preview then
      preview.close()
    end
    vim.cmd('cclose')
    if had_list then
      pcall(vim.cmd, 'silent colder')
    else
      vim.fn.setqflist({}, 'f')
    end
    if vim.api.nvim_win_is_valid(origin_win) then
      vim.api.nvim_set_current_win(origin_win)
    end
    vim.cmd('redraw | echo ""')
  end

  render()
  while true do
    local ok, key = pcall(vim.fn.getcharstr)
    if not ok then
      -- Errors from unrelated vim.schedule callbacks (e.g. quicker.nvim highlighting a list we've
      -- already replaced) surface through getcharstr. Only a real interrupt cancels.
      if tostring(key):find('Keyboard interrupt', 1, true) then
        return close()
      end
      goto continue
    elseif key == KEYS.esc or key == KEYS.c_c then
      return close()
    elseif key == KEYS.cr then
      local item = current[selected]
      close()
      if item then
        (opts.on_select or open_item)(item, query)
      elseif opts.on_empty then
        opts.on_empty(query)
      end
      return
    elseif key == KEYS.c_n or key == KEYS.c_j or key == KEYS.down then
      selected = math.min(selected + 1, #current)
    elseif key == KEYS.c_p or key == KEYS.c_k or key == KEYS.up then
      selected = math.max(selected - 1, 1)
    elseif key == KEYS.bs or key == KEYS.del then
      query = query:sub(1, -2)
      selected = 1
    elseif key == KEYS.c_u then
      query = ''
      selected = 1
    elseif key == KEYS.c_w then
      query = query:gsub('%S*%s*$', '')
      selected = 1
    elseif #key == 1 and key:byte() >= 32 or #key > 1 and not key:find('^\128') then
      query = query .. key
      selected = 1
    end
    render()
    ::continue::
  end
end

-- Item sources

local function rg_files(dir, globs)
  local cmd = { 'rg', '--files', '--hidden', '-g', '!.git' }
  for _, glob in ipairs(globs or {}) do
    vim.list_extend(cmd, { '-g', glob })
  end
  local out = vim.system(cmd, { cwd = dir, text = true }):wait().stdout or ''
  return vim.tbl_map(function(line)
    return { text = line, file = dir .. '/' .. line }
  end, vim.split(out, '\n', { trimempty = true }))
end

local function buffer_items(opts)
  opts = opts or {}
  local current = vim.api.nvim_get_current_buf()
  local bufs = vim.tbl_filter(function(buf)
    return vim.bo[buf].buflisted and vim.api.nvim_buf_get_name(buf) ~= '' and not (opts.skip_current and buf == current)
  end, vim.api.nvim_list_bufs())
  table.sort(bufs, function(a, b)
    return vim.fn.getbufinfo(a)[1].lastused > vim.fn.getbufinfo(b)[1].lastused
  end)
  return vim.tbl_map(function(buf)
    local name = vim.api.nvim_buf_get_name(buf)
    local mark = opts.marks and (vim.bo[buf].modified and '+ ' or '  ') or ''
    return { text = mark .. relpath(name), file = name }
  end, bufs)
end

-- Same sources and order as Snacks: session buffers by last use, then v:oldfiles.
local function recent_items()
  local cwd = vim.fn.getcwd() .. '/'
  local current = vim.fs.normalize(vim.api.nvim_buf_get_name(0))
  local bufs = vim.tbl_filter(function(buf)
    return vim.api.nvim_buf_get_name(buf) ~= '' and vim.bo[buf].buftype == ''
  end, vim.api.nvim_list_bufs())
  table.sort(bufs, function(a, b)
    return vim.fn.getbufinfo(a)[1].lastused > vim.fn.getbufinfo(b)[1].lastused
  end)
  local files = vim.tbl_map(vim.api.nvim_buf_get_name, bufs)
  vim.list_extend(files, vim.v.oldfiles)

  local seen, items = {}, {}
  for _, file in ipairs(files) do
    file = vim.fs.normalize(vim.fn.fnamemodify(file, ':p'))
    if not seen[file] then
      seen[file] = true
      if file ~= current and vim.startswith(file, cwd) and vim.uv.fs_stat(file) then
        items[#items + 1] = { text = relpath(file), file = file }
      end
    end
  end
  return items
end

local function git_diff(root, status, path)
  local function git(args)
    local out = vim.system(vim.list_extend({ 'git', '--no-pager', '-c', 'color.ui=never' }, args), { cwd = root, text = true })
      :wait().stdout
    return vim.split(out or '', '\n', { trimempty = true })
  end
  local lines = {}
  if status:sub(1, 1) ~= ' ' then
    vim.list_extend(lines, git({ 'diff', '--cached', '--', path }))
  end
  if status:sub(2, 2) ~= ' ' then
    vim.list_extend(lines, git({ 'diff', '--', path }))
  end
  return #lines > 0 and lines or { '(no diff)' }
end

local function git_items(cwd_only)
  local dir = vim.fn.getcwd()
  local root = vim.fs.root(dir, '.git')
  if not root then
    vim.notify('Not a git repository', vim.log.levels.WARN)
    return nil
  end
  local cmd = { 'git', 'status', '--porcelain=v1', '-z', '--untracked-files=all' }
  if cwd_only and root ~= dir then
    vim.list_extend(cmd, { '--', dir:sub(#root + 2) })
  end
  local parts = vim.split(vim.system(cmd, { cwd = root, text = true }):wait().stdout or '', '\0', { trimempty = true })
  local items = {}
  local i = 1
  while i <= #parts do
    local status, path = parts[i]:sub(1, 2), parts[i]:sub(4)
    if status:find('[RC]') then
      i = i + 1 -- renames and copies are followed by the original path
    end
    local item = { text = status .. ' ' .. path, file = root .. '/' .. path }
    -- New files preview as regular files, everything else as a diff.
    if status ~= '??' and status ~= 'A ' then
      item.preview = function()
        return git_diff(root, status, path), 'diff'
      end
    end
    items[#items + 1] = item
    i = i + 1
  end
  return items
end

local function lsp_pick(title, call, format)
  call(function(result)
    local items = {}
    for _, it in ipairs(result.items) do
      items[#items + 1] = {
        text = format and format(it) or ('%s:%d: %s'):format(relpath(it.filename), it.lnum, vim.trim(it.text or '')),
        file = it.filename,
        lnum = it.lnum,
        col = it.col,
      }
    end
    if #items == 0 then
      return vim.notify('No results', vim.log.levels.INFO)
    elseif #items == 1 then
      return open_item(items[1])
    end
    pick({ title = title, items = items })
  end)
end

local function dedupe(lists)
  local seen, items = {}, {}
  for _, list in ipairs(lists) do
    for _, item in ipairs(list) do
      if not seen[item.file] then
        seen[item.file] = true
        items[#items + 1] = item
      end
    end
  end
  return items
end

local QFPicker = {
  pick = pick,
  files = function()
    return pick({ title = 'Files', items = rg_files(vim.fn.getcwd()) })
  end,
  resume = function()
    if not last then
      return vim.notify('Nothing to resume', vim.log.levels.INFO)
    end
    return pick(vim.tbl_extend('force', last.opts, { query = last.query }))
  end,
  buffers = function()
    return pick({ title = 'Buffers', items = buffer_items({ marks = true }) })
  end,
  live_grep = function()
    local cwd = vim.fn.getcwd()
    return pick({
      title = 'Grep',
      live = function(query)
        if #query < 2 then
          return {}
        end
        local cmd = { 'rg', '--vimgrep', '--smart-case', '--hidden', '-g', '!.git', '--', query }
        local out = vim.system(cmd, { cwd = cwd, text = true }):wait(2000).stdout or ''
        local items = {}
        for line in vim.gsplit(out, '\n', { trimempty = true }) do
          local file, lnum, col, text = line:match('^(.-):(%d+):(%d+):(.*)$')
          if file then
            items[#items + 1] = {
              text = ('%s:%s: %s'):format(file, lnum, vim.trim(text)),
              file = cwd .. '/' .. file,
              lnum = tonumber(lnum),
              col = tonumber(col),
            }
            if #items >= MAX_RESULTS then
              break
            end
          end
        end
        return items
      end,
    })
  end,
  recent_files = function()
    return pick({ title = 'Recent', items = recent_items() })
  end,
  smart = function()
    return pick({
      title = 'Smart',
      items = dedupe({ buffer_items({ skip_current = true }), recent_items(), rg_files(vim.fn.getcwd()) }),
    })
  end,
  git_status = function()
    local items = git_items(false)
    return items and pick({ title = 'Git status', items = items })
  end,
  git_status_cwd = function()
    local items = git_items(true)
    return items and pick({ title = ('Git status (%s)'):format(vim.fn.fnamemodify(vim.fn.getcwd(), ':~')), items = items })
  end,
  lsp_implementations = function()
    return lsp_pick('Implementations', function(on_list)
      vim.lsp.buf.implementation({ on_list = on_list })
    end)
  end,
  lsp_definitions = function()
    return lsp_pick('Definitions', function(on_list)
      vim.lsp.buf.definition({ on_list = on_list })
    end)
  end,
  lsp_type_definitions = function()
    return lsp_pick('Type definitions', function(on_list)
      vim.lsp.buf.type_definition({ on_list = on_list })
    end)
  end,
  lsp_document_symbols = function()
    return lsp_pick('Symbols', function(on_list)
      vim.lsp.buf.document_symbol({ on_list = on_list })
    end, function(it)
      return ('%d: %s'):format(it.lnum, it.text)
    end)
  end,
  lsp_references = function()
    return lsp_pick('References', function(on_list)
      vim.lsp.buf.references(nil, { on_list = on_list })
    end)
  end,
  org_files = function(path)
    return pick({ title = 'Org files', items = rg_files(vim.fn.expand(path), { '*.org' }) })
  end,
  workspaces = function()
    local items = {}
    local longest_name = 0
    for _, workspace in ipairs(require('workspaces').get()) do
      items[#items + 1] = { name = workspace.name, path = workspace.path }
      longest_name = math.max(longest_name, #workspace.name)
    end
    for _, item in ipairs(items) do
      item.text = ('%-' .. longest_name + 2 .. 's%s'):format(item.name, item.path)
    end
    return pick({
      title = 'Workspaces',
      items = items,
      on_select = function(item)
        vim.cmd(('WorkspacesOpen %s'):format(item.name))
      end,
    })
  end,
  rest = function()
    local dir = vim.fn.expand('~/code/requests')
    return pick({
      title = 'Requests',
      items = rg_files(dir),
      on_empty = function(query)
        vim.cmd.edit(('%s/%s.http'):format(dir, query))
      end,
    })
  end,
}

vim.api.nvim_create_user_command('QFind', function()
  QFPicker.files()
end, {})

return QFPicker
