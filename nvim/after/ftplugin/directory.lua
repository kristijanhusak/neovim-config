if not vim.g.builtin_dir then
  return
end

vim.bo.bufhidden = 'wipe'

local utils = require('partials.utils')
local ns_id = vim.api.nvim_create_namespace('directory_browser')
local sep = (vim.fn.exists('+shellslash') == 1 and not vim.o.shellslash) and '\\' or '/'
local escape_chars = '.#~' .. sep
local esc_sep = vim.pesc(sep)

local function add_icons(icons)
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  local directory_icon = ''

  for row, line in ipairs(lines) do
    if vim.endswith(line, '/') then
      vim.api.nvim_buf_set_extmark(0, ns_id, row - 1, 0, {
        virt_text = { { directory_icon .. ' ', 'Directory' } },
        virt_text_pos = 'inline',
      })
    else
      local file_icon, file_icon_hl = icons.get_icon(line, nil, { default = true })
      if file_icon then
        vim.api.nvim_buf_set_extmark(0, ns_id, row - 1, 0, {
          virt_text = { { file_icon .. ' ', file_icon_hl } },
          virt_text_pos = 'inline',
        })
      end
    end
  end
end

local git_icons = {
  Modified = '✹',
  Staged = '✚',
  Untracked = '✭',
  Renamed = '➜',
  Unmerged = '═',
  Ignored = '☒',
  Unknown = '?',
}

local git_higlights = {
  Modified = 'GitSignsChangeNr',
  Staged = 'GitSignsStagedAddNr',
  Untracked = 'GitSignsUntrackedNr',
  Renamed = 'GitSignsStagedAddNr',
  Unmerged = 'GitSignsDelete',
  Ignored = 'Normal',
  Unknown = 'Normal',
}

local function get_indicator_name(us, them)
  if us == '?' and them == '?' then
    return 'Untracked'
  elseif us == ' ' and them == 'M' then
    return 'Modified'
  elseif us:match('[MAC]') then
    return 'Staged'
  elseif us == 'R' then
    return 'Renamed'
  elseif us == 'U' or them == 'U' or (us == 'A' and them == 'A') or (us == 'D' and them == 'D') then
    return 'Unmerged'
  elseif us == '!' then
    return 'Ignored'
  else
    return 'Unknown'
  end
end

local function add_git()
  local path = vim.api.nvim_buf_get_name(0)
  local git_root_result = vim.system({ 'git', 'rev-parse', '--show-toplevel', path }, {}):wait()
  if git_root_result.code ~= 0 then
    return
  end
  local git_root = vim.trim(vim.split(git_root_result.stdout, '\n')[1])
  local git_status_result = vim.system({ 'git', 'status', '--porcelain', path }, {}):wait()
  if git_status_result.code ~= 0 then
    return
  end
  local lines = vim.split(git_status_result.stdout, '\n')

  -- Sort so that unmerged entries (starting with U or .U) come first,
  -- ensuring directories get the correct status when they contain conflicts.
  table.sort(lines, function(a, _)
    return a:match('^U') or a:match('^.U') and true or false
  end)
  local lines_processed = {}

  for _, line in ipairs(lines) do
    if line ~= '' then
      local us, them, file = line:match('^(.)(.)' .. '%s(.+)$')
      if not us then
        goto continue
      end

      if us == 'R' then
        local parts = vim.split(file, ' -> ', { plain = true })
        file = parts[#parts]
      end

      file = vim.fn.fnamemodify(git_root .. sep .. file, ':p')
      local filepath = file:gsub('^' .. vim.pesc(path .. sep), '')
      local filename = filepath and filepath:match('^[^' .. esc_sep .. ']+' .. esc_sep .. '?')
      if not filename then
        goto continue
      end
      local linenr = vim.fn.search('^' .. vim.fn.escape(filename, escape_chars) .. '$', 'nw')
      if linenr > 0 and not lines_processed[linenr] then
        local indicator_name = get_indicator_name(us, them)
        local indicator_icon = git_icons[indicator_name] or '?'
        vim.api.nvim_buf_set_extmark(0, ns_id, linenr - 1, 0, {
          virt_text = { { indicator_icon .. ' ', git_higlights[indicator_name] or 'Normal' } },
        })
        lines_processed[linenr] = true
      end
    end

    ::continue::
  end

  local line_numbers = vim.tbl_keys(lines_processed)
  table.sort(line_numbers)

  vim.keymap.set('n', ']c', function()
    local current_line = vim.api.nvim_win_get_cursor(0)[1]
    for _, line in ipairs(line_numbers) do
      if line > current_line then
        vim.api.nvim_win_set_cursor(0, { line, 0 })
        return
      end
    end
    vim.api.nvim_win_set_cursor(0, { line_numbers[1], 0 })
  end)

  vim.keymap.set('n', '[c', function()
    local current_line = vim.api.nvim_win_get_cursor(0)[1]
    for i = #line_numbers, 1, -1 do
      if line_numbers[i] < current_line then
        vim.api.nvim_win_set_cursor(0, { line_numbers[i], 0 })
        return
      end
    end
    vim.api.nvim_win_set_cursor(0, { line_numbers[#line_numbers], 0 })
  end)
end

local function attach()
  local ok, devicons = pcall(require, 'nvim-web-devicons')
  if ok then
    add_icons(devicons)
  end

  add_git()
end

local function reload()
  vim.api.nvim_feedkeys(utils.esc('<Plug>(nvim-dir-reload)'), 'n', false)
end

local function current_entry()
  local current_dir = vim.api.nvim_buf_get_name(0)
  local line = vim.api.nvim_get_current_line()

  local full_path = vim.fs.joinpath(current_dir, line)

  return full_path, current_dir, line, vim.endswith(line, sep)
end

local function trim_sep(path)
  if vim.endswith(path, sep) then
    return path:sub(1, #path - 1)
  end
  return path
end

local function rename_loaded_buffers(old_path, new_path)
  -- delete new if it exists
  for _, buf in pairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) then
      local buf_name = vim.api.nvim_buf_get_name(buf)
      if buf_name == new_path then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end
  end

  -- rename old to new
  for _, buf in pairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) then
      local buf_name = vim.api.nvim_buf_get_name(buf)
      local exact_match = buf_name == old_path
      local child_match = (buf_name:sub(1, #old_path) == old_path and buf_name:sub(#old_path + 1, #old_path + 1) == sep)
      if exact_match or child_match then
        vim.api.nvim_buf_set_name(buf, new_path .. buf_name:sub(#old_path + 1))
        -- to avoid the 'overwrite existing file' error message on write for
        -- normal files
        local buftype = vim.api.nvim_get_option_value('buftype', { buf = buf })

        if buftype == '' then
          vim.api.nvim_buf_call(buf, function()
            vim.cmd('silent! write!')
            vim.cmd('edit')
          end)
        end
      end
    end
  end
end

vim.keymap.set('n', 'a', function()
  vim.ui.input({
    prompt = 'Enter new file name: ',
  }, function(input)
    if not input or vim.trim(input) == '' then
      vim.notify('No input', vim.log.levels.WARN)
      return
    end
    local did_create = require('lsp-file-operations.did-create')
    local will_create = require('lsp-file-operations.will-create')

    local _, current_dir = current_entry()
    local full_path = vim.fs.joinpath(current_dir, input)
    local has_file = vim.fn.fnamemodify(full_path, ':t') ~= ''
    local label = has_file and 'file' or 'directory'
    will_create.callback({ fname = trim_sep(full_path) })

    local dir_to_create = not has_file and full_path or vim.fn.fnamemodify(full_path, ':p:h')

    if dir_to_create and dir_to_create ~= '' then
      local result = vim.fn.mkdir(dir_to_create, 'p')
      if result == 0 then
        vim.notify(
          ('Could not create directory: %s'):format(dir_to_create),
          vim.log.levels.ERROR,
          { title = 'Directory Browser' }
        )
        return
      end
    end

    local ok, fd = pcall(vim.uv.fs_open, full_path, 'w', 420)
    if not ok or type(fd) ~= 'number' then
      vim.notify(
        ('Could not create %s: %s'):format(label, full_path),
        vim.log.levels.ERROR,
        { title = 'Directory Browser' }
      )
      return
    end
    vim.uv.fs_close(fd)

    did_create.callback({ fname = trim_sep(full_path) })
    vim.notify(('Created %s: %s'):format(label, full_path), nil, { title = 'Directory Browser' })
    reload()
  end)
end, { buffer = true, nowait = true, desc = 'Create file' })

vim.keymap.set('n', 'd', function()
  local full_path, _, file, is_dir = current_entry()
  local label = is_dir and 'directory' or 'file'
  vim.ui.input({
    prompt = ('Delete %s %s? [y/N]'):format(label, file),
  }, function(input)
    if (input or ''):lower() ~= 'y' then
      return
    end

    local did_delete = require('lsp-file-operations.did-delete')
    local will_delete = require('lsp-file-operations.will-delete')

    will_delete.callback({ fname = trim_sep(full_path) })
    vim.fn.delete(full_path, vim.fn.isdirectory(full_path) == 1 and 'rf' or '')
    did_delete.callback({ fname = trim_sep(full_path) })

    vim.notify(('Deleted %s: %s'):format(label, full_path), nil, { title = 'Directory Browser' })
    reload()
  end)
end, { buffer = true, nowait = true, desc = 'Delete file' })

vim.keymap.set('n', 'r', function()
  local full_path, current_dir, file, is_dir = current_entry()
  local type = is_dir and 'directory' or 'file'
  vim.ui.input({
    prompt = ('Rename %s %s'):format(type, file),
    default = file,
  }, function(input)
    if not input or vim.trim(input) == '' then
      vim.notify('No input', vim.log.levels.WARN)
      return
    end

    local did_rename = require('lsp-file-operations.did-rename')
    local will_rename = require('lsp-file-operations.will-rename')

    local new_full_path = vim.fs.joinpath(current_dir, input)

    local has_file = vim.fn.fnamemodify(new_full_path, ':t') ~= ''

    if has_file then
      local dir = vim.fn.fnamemodify(new_full_path, ':p:h')
      local result = vim.fn.mkdir(dir, 'p')
      if result == 0 then
        vim.notify(
          ('Could not create directory: %s'):format(dir),
          vim.log.levels.ERROR,
          { title = 'Directory Browser' }
        )
        return
      end
    end

    local lsp_payload = {
      old_name = trim_sep(full_path),
      new_name = trim_sep(new_full_path),
    }

    will_rename.callback(lsp_payload)
    local success, err = vim.uv.fs_rename(full_path, new_full_path)

    if not success then
      vim.notify(('Could not rename %s: %s'):format(type, err), vim.log.levels.ERROR, { title = 'Directory Browser' })
      return
    end

    rename_loaded_buffers(full_path, new_full_path)

    did_rename.callback(lsp_payload)
    vim.notify(('Renamed %s to %s'):format(full_path, new_full_path), nil, { title = 'Directory Browser' })
    reload()
  end)
end, { buffer = true, nowait = true, desc = 'Rename file' })

vim.keymap.set('n', 'q', function()
  vim.cmd('bw!')
end, { buffer = true, nowait = true, desc = 'Quit' })

local function keymap(key)
  return function()
    local view = vim.fn.winsaveview()
    vim.api.nvim_feedkeys(utils.esc(key), 'n', false)
    vim.schedule(function()
      vim.fn.winrestview(view)
    end)
  end
end

vim.keymap.set('n', 'o', keymap('<Plug>(nvim-dir-open)'), { buffer = true, nowait = true, desc = 'Open file/dir' })
vim.keymap.set('n', 'L', keymap('<Plug>(nvim-dir-open)'), { buffer = true, nowait = true, desc = 'Open file/dir' })
vim.keymap.set('n', 'H', keymap('<Plug>(nvim-dir-up)'), { buffer = true, nowait = true, desc = 'Go up dir' })
vim.keymap.set('n', '-', keymap('<Plug>(nvim-dir-up)'), { buffer = true, nowait = true, desc = 'Go up dir' })
vim.keymap.set('n', 's', function()
  local full_path, _, _, _ = current_entry()
  vim.cmd.vnew(full_path)
end, { buffer = true, nowait = true, desc = 'Open file/dir in vert split' })

vim.keymap.set('n', 'X', function()
  local full_path, _, _, _ = current_entry()
  vim.fn.execute(('silent !xdg-open %s'):format(vim.fn.shellescape(full_path)))
end, { buffer = true, nowait = true, desc = 'Open file/dir in vert split' })

vim.api.nvim_create_autocmd('TextChanged', {
  buffer = 0,
  callback = function()
    attach()
  end,
})
