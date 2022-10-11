local git = {}

local function add_mappings()
  vim.keymap.set(
    'n',
    ']q',
    ':cnext <BAR> :call v:lua.kris.git.diff_current_quickfix_entry()<CR>',
    { buffer = true, silent = true }
  )
  vim.keymap.set(
    'n',
    '[q',
    ':cprevious <BAR> :call v:lua.kris.git.diff_current_quickfix_entry()<CR>',
    { buffer = true, silent = true }
  )
  vim.cmd([[11copen]])
  vim.cmd.wincmd('p')
end

function git.view_git_history()
  vim.cmd.only()
  vim.cmd([[Git difftool --name-only ! !^@]])
  git.diff_current_quickfix_entry()
  vim.cmd.copen()
  vim.keymap.set('n', '<CR>', '<CR><BAR>:call v:lua.kris.git.diff_current_quickfix_entry()<CR>', {
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

function git.add_commit_prefix_from_branch()
  if vim.bo.filetype ~= 'gitcommit' then
    return
  end

  if vim.fn.expand('%') == '.git/COMMIT_EDITMSG' and vim.fn.getline(1) == '' then
    local head = vim.fn['FugitiveHead']()
    if head and head:find('/') then
      vim.fn.setline(1, '[' .. vim.fn.split(head, '/')[2] .. '] ')
      vim.cmd.startinsert({ bang = true })
    end
  end
end

local git_group = vim.api.nvim_create_augroup('gitcommit', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'git',
  callback = function()
    vim.wo.foldenable = true
    vim.wo.foldmethod = 'syntax'
    vim.keymap.set('n', '<Space>', 'za', { silent = true, buffer = true })
  end,
  group = git_group,
})
vim.api.nvim_create_autocmd('VimEnter', {
  pattern = '*',
  callback = git.add_commit_prefix_from_branch,
  group = git_group,
})

vim.api.nvim_create_user_command('DiffHistory', git.view_git_history, { force = true })

_G.kris.git = git
