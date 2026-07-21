local sep = (vim.fn.exists('+shellslash') == 1 and not vim.o.shellslash) and '\\' or '/'
local escape_chars = '.#~' .. sep
local esc_sep = vim.pesc(sep)
local ns_id = vim.api.nvim_create_namespace('directory_browser_git')

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

local function add_git(bufnr)
  local path = vim.api.nvim_buf_get_name(bufnr)
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
      local filepath = file:gsub('^' .. vim.pesc(path), '')
      local filename = filepath and filepath:match('^[^' .. esc_sep .. ']+' .. esc_sep .. '?')
      if not filename then
        goto continue
      end
      local linenr = vim.fn.search('^' .. vim.fn.escape(filename, escape_chars) .. '$', 'nw')
      if linenr > 0 and not lines_processed[linenr] then
        local indicator_name = get_indicator_name(us, them)
        local indicator_icon = git_icons[indicator_name] or '?'
        vim.api.nvim_buf_set_extmark(bufnr, ns_id, linenr - 1, 0, {
          virt_text = { { indicator_icon .. ' ', git_higlights[indicator_name] or 'Normal' } },
          hl_mode = 'combine',
        })
        local hl = git_higlights[indicator_name]
        if hl then
          vim.api.nvim_buf_set_extmark(bufnr, ns_id, linenr - 1, 0, {
            end_col = #vim.api.nvim_buf_get_lines(bufnr, linenr - 1, linenr, false)[1],
            hl_group = hl,
            hl_mode = 'combine',
          })
        end
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

return {
  attach = function(bufnr)
    add_git(bufnr)
  end
}
