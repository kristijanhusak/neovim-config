local ns_id = vim.api.nvim_create_namespace('directory_browser_actions')
local utils = require('partials.utils')
local dir_utils = require('partials.custom_plugins.dir.utils')

vim.api.nvim_set_hl(0, 'DirectoryCut', { undercurl = true })
vim.api.nvim_set_hl(0, 'DirectoryCopy', { underline = true })

local cut_state = {}
local copy_state = {}

local function render_state(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  for row, line in ipairs(lines) do
    local current_dir = vim.api.nvim_buf_get_name(bufnr)
    local full_path = vim.fs.joinpath(current_dir, line)
    if cut_state[full_path] then
      vim.api.nvim_buf_set_extmark(bufnr, ns_id, row - 1, 0, {
        virt_text = { { '󰆐 ', 'Title' } },
        hl_mode = 'combine',
      })

      vim.api.nvim_buf_set_extmark(bufnr, ns_id, row - 1, 0, {
        end_col = #line,
        hl_group = 'DirectoryCut',
      })
    end

    if copy_state[full_path] then
      vim.api.nvim_buf_set_extmark(bufnr, ns_id, row - 1, 0, {
        virt_text = { { ' ', 'Title' } },
        hl_mode = 'combine',
      })

      vim.api.nvim_buf_set_extmark(bufnr, ns_id, row - 1, 0, {
        end_col = #line,
        hl_group = 'DirectoryCopy',
      })
    end
  end
end

local function add_mappings(bufnr)
  vim.keymap.set('n', 'a', function()
    vim.ui.input({
      prompt = 'Enter new file name: ',
    }, function(input)
      if not input or vim.trim(input) == '' then
        vim.notify('No input', vim.log.levels.WARN)
        return
      end

      local _, current_dir = dir_utils.current_entry(bufnr)
      local full_path = vim.fs.joinpath(current_dir, input)
      local has_file = vim.fn.fnamemodify(full_path, ':t') ~= ''
      local label = has_file and 'file' or 'directory'
      local lsp_create = dir_utils.lsp_create(full_path)
      lsp_create.before()

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

      if has_file then
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
      end

      lsp_create.after()
      vim.notify(('Created %s: %s'):format(label, full_path), nil, { title = 'Directory Browser' })
      dir_utils.reload()
    end)
  end, { buffer = bufnr, nowait = true, desc = 'Create file' })

  vim.keymap.set('n', 'd', function()
    local full_path, _, file, is_dir = dir_utils.current_entry(bufnr)
    local label = is_dir and 'directory' or 'file'
    vim.ui.input({
      prompt = ('Delete %s %s? [y/N]'):format(label, file),
    }, function(input)
      if (input or ''):lower() ~= 'y' then
        return
      end

      local lsp_delete = dir_utils.lsp_delete(full_path)

      lsp_delete.before()
      vim.fn.delete(full_path, vim.fn.isdirectory(full_path) == 1 and 'rf' or '')
      lsp_delete.after()

      vim.notify(('Deleted %s: %s'):format(label, full_path), nil, { title = 'Directory Browser' })
      dir_utils.reload()
    end)
  end, { buffer = bufnr, nowait = true, desc = 'Delete file' })

  vim.keymap.set('n', 'r', function()
    local full_path, current_dir, file, is_dir = dir_utils.current_entry(bufnr)
    local type = is_dir and 'directory' or 'file'
    vim.ui.input({
      prompt = ('Rename %s %s'):format(type, file),
      default = file,
    }, function(input)
      if not input or vim.trim(input) == '' then
        vim.notify('No input', vim.log.levels.WARN)
        return
      end

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

      local lsp_rename = dir_utils.lsp_rename(full_path, new_full_path)
      lsp_rename.before()
      local success, err = vim.uv.fs_rename(full_path, new_full_path)

      if not success then
        vim.notify(('Could not rename %s: %s'):format(type, err), vim.log.levels.ERROR, { title = 'Directory Browser' })
        return
      end

      lsp_rename.after()
      vim.notify(('Renamed %s to %s'):format(full_path, new_full_path), nil, { title = 'Directory Browser' })
      dir_utils.reload()
    end)
  end, { buffer = bufnr, nowait = true, desc = 'Rename file' })

  local function keymap(key)
    return function()
      local view = vim.fn.winsaveview()
      vim.api.nvim_feedkeys(utils.esc(key), 'n', false)
      vim.schedule(function()
        vim.fn.winrestview(view)
      end)
    end
  end

  vim.keymap.set('n', 'o', keymap('<Plug>(nvim-dir-open)'), { buffer = bufnr, nowait = true, desc = 'Open file/dir' })
  vim.keymap.set('n', 'L', keymap('<Plug>(nvim-dir-open)'), { buffer = bufnr, nowait = true, desc = 'Open file/dir' })
  vim.keymap.set('n', 'H', keymap('<Plug>(nvim-dir-up)'), { buffer = bufnr, nowait = true, desc = 'Go up dir' })
  vim.keymap.set('n', '-', keymap('<Plug>(nvim-dir-up)'), { buffer = bufnr, nowait = true, desc = 'Go up dir' })

  vim.keymap.set('n', 'q', function()
    vim.cmd('bw!')
  end, { buffer = bufnr, nowait = true, desc = 'Quit' })

  vim.keymap.set('n', 's', function()
    local full_path, _, _, _ = dir_utils.current_entry(bufnr)
    vim.cmd.vnew(full_path)
  end, { buffer = bufnr, nowait = true, desc = 'Open file/dir in vert split' })

  vim.keymap.set('n', 'X', function()
    local full_path, _, _, _ = dir_utils.current_entry(bufnr)
    vim.fn.execute(('silent !xdg-open %s'):format(vim.fn.shellescape(full_path)))
  end, { buffer = bufnr, nowait = true, desc = 'Open file/dir in vert split' })

  vim.keymap.set('n', 'c', function()
    local full_path, _, _, _ = dir_utils.current_entry(bufnr)
    if copy_state[full_path] then
      copy_state[full_path] = nil
    else
      copy_state[full_path] = true
      cut_state[full_path] = nil
    end
    dir_utils.reload()
  end, { buffer = bufnr, nowait = true, desc = 'Mark/Unmark for copy' })

  vim.keymap.set('n', 'x', function()
    local full_path, _, _, _ = dir_utils.current_entry(bufnr)
    if cut_state[full_path] then
      cut_state[full_path] = nil
    else
      cut_state[full_path] = true
      copy_state[full_path] = nil
    end
    dir_utils.reload()
  end, { buffer = bufnr, nowait = true, desc = 'Mark/Unmark for cut' })

  vim.keymap.set('n', 'p', function()
    local current_dir = vim.api.nvim_buf_get_name(0)
    for path, _ in pairs(copy_state) do
      local new_path = vim.fs.joinpath(current_dir, vim.fn.fnamemodify(path, ':t'))
      local has_file = vim.fn.fnamemodify(new_path, ':t') ~= ''
      if has_file then
        local dir = vim.fn.fnamemodify(new_path, ':p:h')
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

      local lsp_create = dir_utils.lsp_create(new_path)
      lsp_create.before()
      vim.fn.filecopy(path, new_path)
      lsp_create.after()
    end

    for path, _ in pairs(cut_state) do
      local new_path = vim.fs.joinpath(current_dir, vim.fn.fnamemodify(path, ':t'))
      local has_file = vim.fn.fnamemodify(new_path, ':t') ~= ''
      if has_file then
        local dir = vim.fn.fnamemodify(new_path, ':p:h')
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

      local lsp_rename = dir_utils.lsp_rename(path, new_path)
      lsp_rename.before()
      vim.fn.rename(path, new_path)
      lsp_rename.after()
    end

    copy_state = {}
    cut_state = {}
    dir_utils.reload()
  end, { buffer = bufnr, nowait = true, desc = 'Paste marked files' })
end

local function attach(bufnr)
  vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
  render_state(bufnr)
  add_mappings(bufnr)
end

return {
  attach = attach,
}
