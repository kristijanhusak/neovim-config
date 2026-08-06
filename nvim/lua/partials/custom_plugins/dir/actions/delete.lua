local dir_utils = require('partials.custom_plugins.dir.utils')

local function delete_action()
  local full_path, _, file, is_dir = dir_utils.current_entry()
  local label = is_dir and 'directory' or 'file'
  vim.ui.input({
    prompt = ('Delete %s %s? [y/N]'):format(label, file),
  }, function(input)
    if (input or ''):lower() ~= 'y' then
      return
    end

    local lsp_delete = dir_utils.lsp_delete(full_path)

    lsp_delete.before()
    local result = vim.fn.delete(full_path, vim.fn.isdirectory(full_path) == 1 and 'rf' or '')
    if result ~= 0 then
      vim.notify(('Could not delete %s: %s'):format(label, full_path), vim.log.levels.ERROR, { title = 'Directory Browser' })
      dir_utils.reload()
      return
    end

    lsp_delete.after()
    vim.notify(('Deleted %s: %s'):format(label, full_path), nil, { title = 'Directory Browser' })
    dir_utils.reload()
  end)
end

return {
  execute = delete_action,
}
