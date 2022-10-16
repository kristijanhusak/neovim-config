local function git_history_for_file()
  local config = require('lgh').config
  local current_file = vim.fn.expand('%:p')
  local current_filename = vim.fn.expand('%:t')
  local path = config.basedir .. vim.fn.hostname() .. current_file .. '/' .. current_filename
  local stat = vim.loop.fs_stat(path)
  if not stat or stat.type ~= 'file' then
    return vim.notify('No git history for this file', vim.log.levels.ERROR)
  end
  return vim.cmd.vsplit(path)
end

local githistory = {
  install = function(packager)
    return packager.add('m42e/lgh.nvim')
  end,
}
githistory.setup = function()
  vim.api.nvim_create_user_command('HistoryGit', git_history_for_file, {})
  return githistory
end

return githistory
