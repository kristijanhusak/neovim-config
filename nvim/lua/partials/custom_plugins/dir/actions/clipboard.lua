local dir_utils = require('partials.custom_plugins.dir.utils')

local cut_state = {}
local copy_state = {}

local function mark_copy_action()
  local full_path, _, _, _ = dir_utils.current_entry()
  if copy_state[full_path] then
    copy_state[full_path] = nil
  else
    copy_state[full_path] = true
    cut_state[full_path] = nil
  end
  dir_utils.reload()
end

local function mark_cut_action()
  local full_path, _, _, _ = dir_utils.current_entry()
  if cut_state[full_path] then
    cut_state[full_path] = nil
  else
    cut_state[full_path] = true
    copy_state[full_path] = nil
  end
  dir_utils.reload()
end

-- Resolves the destination path, asking the user what to do when it already exists.
-- Calls `callback` with the final path, or nil when the operation should be cancelled.
local function resolve_new_path(path, dir, state, operation, callback)
  local function cancel(remove_from_clipboard)
    local msg = ('Cancelling %s operation for %s.'):format(operation, path)
    if remove_from_clipboard then
      msg = msg .. '\nRemoving from clipboard.'
      state[path] = nil
    end
    vim.notify(msg, vim.log.levels.INFO, { title = 'Directory Browser' })
    callback(nil)
  end

  local function check(new_path)
    local stat = vim.uv.fs_stat(new_path)
    if not stat then
      return callback(new_path)
    end

    local choice = vim.fn.confirm(
      ('%s already exists: %s. Overwrite?'):format(stat.type, new_path),
      '&Overwrite\n&Rename\n&No\n&Cancel',
      4
    )

    if choice == 1 then
      return callback(new_path)
    end

    if choice == 2 then
      return vim.ui.input({ prompt = 'New name: ', default = vim.fn.fnamemodify(new_path, ':t') }, function(name)
        if name and name ~= '' then
          check(vim.fs.joinpath(dir, name))
        else
          cancel(false)
        end
      end)
    end

    cancel(choice == 3)
  end

  check(vim.fs.joinpath(dir, vim.fn.fnamemodify(path, ':t')))
end

local function copy_to(path, new_path)
  local has_file = vim.fn.fnamemodify(new_path, ':t') ~= ''
  if has_file then
    local dir = vim.fn.fnamemodify(new_path, ':p:h')
    local result = vim.fn.mkdir(dir, 'p')
    if result == 0 then
      vim.notify(('Could not create directory: %s'):format(dir), vim.log.levels.ERROR, { title = 'Directory Browser' })
      return
    end
  end

  local lsp_create = dir_utils.lsp_create(new_path)
  lsp_create.before()
  local success, err = vim.uv.fs_copyfile(path, new_path, { excl = false, ficlone = false, ficlone_force = false })
  if not success then
    vim.notify(
      ('Could not copy %s to %s: %s'):format(path, new_path, err),
      vim.log.levels.ERROR,
      { title = 'Directory Browser' }
    )
    return
  end
  lsp_create.after()
  copy_state[path] = nil
end

local function process_copy(path, dir, done)
  resolve_new_path(path, dir, copy_state, 'copy', function(new_path)
    if new_path then
      copy_to(path, new_path)
    end
    done()
  end)
end

local function cut_to(path, new_path)
  local has_file = vim.fn.fnamemodify(new_path, ':t') ~= ''
  if has_file then
    local dir = vim.fn.fnamemodify(new_path, ':p:h')
    local result = vim.fn.mkdir(dir, 'p')
    if result == 0 then
      vim.notify(('Could not create directory: %s'):format(dir), vim.log.levels.ERROR, { title = 'Directory Browser' })
      return
    end
  end

  local lsp_rename = dir_utils.lsp_rename(path, new_path)
  lsp_rename.before()
  local success, err, err_code = os.rename(path, new_path)
  if not success then
    vim.notify(
      ('Could not move %s to %s: %s (error code: %s)'):format(path, new_path, err, err_code),
      vim.log.levels.ERROR,
      { title = 'Directory Browser' }
    )
    return
  end
  lsp_rename.after()
  cut_state[path] = nil
end

local function process_cut(path, dir, done)
  resolve_new_path(path, dir, cut_state, 'cut', function(new_path)
    if new_path then
      cut_to(path, new_path)
    end
    done()
  end)
end

local function paste_action()
  local dir = vim.api.nvim_buf_get_name(0)
  local queue = {}
  for path, _ in pairs(copy_state) do
    table.insert(queue, function(done)
      process_copy(path, dir, done)
    end)
  end
  for path, _ in pairs(cut_state) do
    table.insert(queue, function(done)
      process_cut(path, dir, done)
    end)
  end

  -- Items run one at a time since each one may wait on a prompt.
  local function next_item()
    local item = table.remove(queue, 1)
    if not item then
      return dir_utils.reload()
    end
    item(next_item)
  end
  next_item()
end

return {
  mark_copy = mark_copy_action,
  mark_cut = mark_cut_action,
  copy_state = copy_state,
  cut_state = cut_state,
  paste = paste_action,
}
