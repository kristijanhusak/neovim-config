local dir_utils = require('partials.custom_plugins.dir.utils')

local function process_create(full_path)
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
end

local function create_action(default_value)
  vim.ui.input({
    prompt = 'Enter new file name: ',
    default = default_value or '',
  }, function(input)
    if not input or vim.trim(input) == '' then
      vim.notify('No input', vim.log.levels.WARN)
      return
    end

    local _, current_dir = dir_utils.current_entry()
    local full_path = vim.fs.joinpath(current_dir, input)
    local stat = vim.uv.fs_stat(full_path)
    if stat then
      local choice = vim.fn.confirm(('%s already exists: %s. Overwrite?'):format(stat.type, full_path), '&Yes\n&No\n&Cancel', 2)
      if choice == 2 then
        return create_action(input)
      end
      if choice ~= 1 then
        return
      end
    end
    process_create(full_path)
  end)
end

return {
  execute = create_action,
}
