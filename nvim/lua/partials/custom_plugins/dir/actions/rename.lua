local dir_utils = require('partials.custom_plugins.dir.utils')

local function process_rename(full_path, new_full_path)
  local has_file = vim.fn.fnamemodify(new_full_path, ':t') ~= ''

  if has_file then
    local dir = vim.fn.fnamemodify(new_full_path, ':p:h')
    local result = vim.fn.mkdir(dir, 'p')
    if result == 0 then
      vim.notify(('Could not create directory: %s'):format(dir), vim.log.levels.ERROR, { title = 'Directory Browser' })
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
end

local function rename_action(default_value)
  local full_path, current_dir, file, is_dir = dir_utils.current_entry()
  local type = is_dir and 'directory' or 'file'

  vim.ui.input({
    prompt = ('Rename %s %s'):format(type, file),
    default = default_value or file,
  }, function(input)
    if not input or vim.trim(input) == '' then
      vim.notify('No input', vim.log.levels.WARN)
      return
    end

    local new_full_path = vim.fs.joinpath(current_dir, input)
    local stat = vim.uv.fs_stat(new_full_path)

    if stat then
      local choice = vim.fn.confirm(('%s already exists: %s. Overwrite?'):format(stat.type, new_full_path), '&Yes\n&No\n&Cancel', 2)
      if choice == 2 then
        return rename_action(input)
      end
      if choice ~= 1 then
        return
      end
    end

    process_rename(full_path, new_full_path)
  end)
end

return {
  execute = rename_action
}
