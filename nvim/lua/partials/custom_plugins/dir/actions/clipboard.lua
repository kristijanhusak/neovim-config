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

local function process_copy(path)
  local current_dir = vim.api.nvim_buf_get_name(0)
  local new_path = vim.fs.joinpath(current_dir, vim.fn.fnamemodify(path, ':t'))
  local stat = vim.uv.fs_stat(new_path)

  if stat then
    local choice =
      vim.fn.confirm(('%s already exists: %s. Overwrite?'):format(stat.type, new_path), '&Yes\n&No\n&Cancel', 3)
    if choice ~= 1 then
      local msg = 'Cancelling copy operation for ' .. path .. '.'
      if choice == 2 then
        msg = msg .. '\nRemoving from clipboard.'
        copy_state[path] = nil
      end
      vim.notify(msg, vim.log.levels.INFO, { title = 'Directory Browser' })
      return
    end
  end

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

local function process_cut(path)
  local current_dir = vim.api.nvim_buf_get_name(0)
  local new_path = vim.fs.joinpath(current_dir, vim.fn.fnamemodify(path, ':t'))
  local stat = vim.uv.fs_stat(new_path)

  if stat then
    local choice =
      vim.fn.confirm(('%s already exists: %s. Overwrite?'):format(stat.type, new_path), '&Yes\n&No\n&Cancel', 3)
    if choice ~= 1 then
      local msg = 'Cancelling cut operation for ' .. path .. '.'
      if choice == 2 then
        msg = msg .. '\nRemoving from clipboard.'
        cut_state[path] = nil
      end
      vim.notify(msg, vim.log.levels.INFO, { title = 'Directory Browser' })
      return
    end
  end

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

local function paste_action()
  for path, _ in pairs(copy_state) do
    process_copy(path)
  end

  for path, _ in pairs(cut_state) do
    process_cut(path)
  end

  dir_utils.reload()
end

return {
  mark_copy = mark_copy_action,
  mark_cut = mark_cut_action,
  copy_state = copy_state,
  cut_state = cut_state,
  paste = paste_action,
}
