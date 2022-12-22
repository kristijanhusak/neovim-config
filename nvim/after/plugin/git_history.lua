local git = {}
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
        vim.notify('Error saving file to git history: ' .. data[1], vim.log.levels.ERROR)
      end
    end,
  })
end

local function add_mappings()
  vim.keymap.set('n', ']q', function()
    vim.cmd.cnext()
    git.diff_current_quickfix_entry()
  end, { buffer = true, silent = true })
  vim.keymap.set('n', '[q', function()
    vim.cmd.cprevious()
    git.diff_current_quickfix_entry()
  end, { buffer = true, silent = true })
  vim.cmd([[11copen]])
  vim.cmd.wincmd('p')
end

function git.view_git_history()
  vim.cmd.only()
  vim.cmd([[Git difftool --name-only ! !^@]])
  git.diff_current_quickfix_entry()
  vim.cmd.copen()
  vim.keymap.set('n', '<CR>', function()
    vim.api.nvim_feedkeys('<CR>', 'n', true)
    git.diff_current_quickfix_entry()
  end, {
    buffer = true,
    silent = true,
  })
  vim.cmd.wincmd('p')
end

function git.diff_current_quickfix_entry()
  local win = vim.fn.winnr()
  for _, window in ipairs(vim.fn.getwininfo()) do
    if window.winnr ~= win and vim.fn.bufname(window.bufnr):match('^fugitive:') then
      vim.cmd.bdelete(window.bufnr)
    end
  end
  vim.cmd.cc()
  add_mappings()

  local qf = vim.fn.getqflist({ context = 0, idx = 0 })
  if qf.idx and type(qf.context) == 'table' and vim.tbl_islist(qf.context.items) then
    local diff = qf.context.items[qf.idx] and qf.context.items[qf.idx].diff or {}
    for _, i in ipairs(vim.fn.reverse(vim.fn.range(#diff))) do
      vim.cmd((i > 0 and 'leftabove' or 'rightbelow') .. ' vert diffsplit ' .. vim.fn.fnameescape(diff[i + 1].filename))
      add_mappings()
    end
  end
end

vim.api.nvim_create_autocmd('BufWritePost', {
  pattern = '*',
  callback = save_to_git_history,
  group = augroup,
})
vim.api.nvim_create_user_command('DiffHistory', git.view_git_history, { force = true })
