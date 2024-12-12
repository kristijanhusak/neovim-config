local augroup = vim.api.nvim_create_augroup('GitHistory', { clear = true })
local uv = vim.loop

local function save_to_git_history()
  if vim.bo.buftype ~= '' then
    return
  end
  local git_dir = uv.cwd() .. '/.git'
  local is_git = uv.fs_stat(git_dir)
  if not is_git or is_git.type ~= 'directory' then
    return
  end
  local filepath = vim.api.nvim_buf_get_name(0)
  local path = ('%s/history%s'):format(git_dir, filepath)
  local file_dir = vim.fs.dirname(path)
  local has_dir = uv.fs_stat(file_dir)
  if not has_dir or has_dir.type ~= 'directory' then
    vim.fn.mkdir(file_dir, 'p')
  end
  vim.fn.jobstart({ 'cp', filepath, path }, {
    on_stderr = function(_, data)
      if data and data[1] and data[1] ~= '' then
        vim.notify('Error saving file to git history: ' .. data[1], vim.log.levels.ERROR, {
          title = 'Git History',
        })
      end
    end,
  })
end

vim.api.nvim_create_autocmd('BufWritePost', {
  pattern = '*',
  callback = save_to_git_history,
  group = augroup,
})
