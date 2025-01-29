local augroup = vim.api.nvim_create_augroup('GitHistory', { clear = true })
local uv = vim.loop

local function save_to_git_history()
  if vim.bo.buftype ~= '' then
    return
  end
  local cwd = uv.cwd()
  if not cwd then
    return
  end
  local git_dir = cwd .. '/.git'

  if not uv.fs_stat(git_dir) then
    cwd = vim.fs.root(cwd, '.git')
    if not cwd then
      return
    end
    git_dir = cwd .. '/.git'
  end
  if not uv.fs_stat(git_dir) then
    return
  end
  local filepath = vim.fn.expand('%:p')
  if not vim.startswith(filepath, cwd) then
    return
  end
  local path = ('%s/history%s'):format(git_dir, filepath:sub(#cwd + 1))
  local file_dir = vim.fs.dirname(path)
  local has_dir = uv.fs_stat(file_dir)
  if not has_dir or has_dir.type ~= 'directory' then
    vim.fn.mkdir(file_dir, 'p')
  end
  local result = vim.system({ 'cp', filepath, path }):wait()
  if result.stderr and result.stderr ~= '' then
    vim.notify('Error saving file to git history: ' .. result.stderr, vim.log.levels.ERROR, {
      title = 'Git History',
    })
  end
end

vim.api.nvim_create_autocmd('BufWritePost', {
  pattern = '*',
  callback = save_to_git_history,
  group = augroup,
})
