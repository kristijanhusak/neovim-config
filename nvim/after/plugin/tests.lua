local last_cmd = nil
local augroup = vim.api.nvim_create_augroup('kris_test_runner', { clear = true })

local function is_terminal_buf(bufnr)
  return vim.bo[bufnr].buftype == 'terminal' and vim.b[bufnr].last_cmd ~= nil
end

local function get_terminal_bufnr()
  for _, win in ipairs(vim.fn.getwininfo()) do
    if is_terminal_buf(win.bufnr) then
      return win.bufnr, win.winid
    end
  end
  return nil, -1
end

local notify = function(msg, level)
  vim.notify(msg, level or vim.log.levels.WARN, {
    title = 'Test runner',
    id = 'kris_test_runner',
  })
end

local win_config = function()
  return {
    width = math.max(95, math.floor(vim.o.columns * 0.25)),
    height = math.floor(vim.o.lines * 0.9),
    relative = 'editor',
    anchor = 'NE',
    row = 1,
    col = vim.o.columns - 1,
    focusable = true,
    border = 'rounded',
  }
end

local function exec(cmd)
  local bufnr = get_terminal_bufnr()
  local is_currently_in_terminal = false
  if bufnr then
    is_currently_in_terminal = vim.api.nvim_get_current_buf() == bufnr
    vim.cmd(bufnr .. 'bw!')
  end

  bufnr = vim.api.nvim_create_buf(false, is_currently_in_terminal)
  local win = vim.api.nvim_open_win(bufnr, true, win_config())

  vim.keymap.set('n', 'q', function()
    vim.api.nvim_win_set_config(win, { hide = true })
    vim.cmd('wincmd p')
  end, { buffer = bufnr })

  notify('Running tests...', vim.log.levels.INFO)

  vim.fn.termopen(cmd, {
    on_exit = function(_, code)
      if code == 0 then
        return notify('✅ Tests passed!', vim.log.levels.INFO)
      end
      notify('❌ Tests failed.', vim.log.levels.ERROR)
    end,
  })

  vim.b[bufnr].last_cmd = cmd
  last_cmd = cmd
  vim.cmd.norm({ 'G', bang = true })
  if not is_currently_in_terminal then
    vim.cmd.wincmd('p')
  end
end

local function run_file(file_cmd)
  local filename = vim.fn.expand('%:.')

  if is_terminal_buf(vim.api.nvim_get_current_buf()) then
    return exec(vim.b.last_cmd)
  end

  local is_test_file_check = vim.tbl_get(vim.g.test_commands, 'is_test_file') or function()
    return true
  end

  local is_test_file = is_test_file_check(filename)

  if is_test_file then
    return exec(file_cmd:gsub('{file}', vim.fn.fnameescape(filename)))
  end

  if last_cmd then
    return exec(last_cmd)
  end

  return notify('Not a test file')
end

vim.keymap.set('n', '<leader>xx', function()
  local file_cmd = vim.tbl_get(vim.g.test_commands, 'file')
  if not file_cmd then
    return notify('No test command for file')
  end
  return run_file(file_cmd)
end, { desc = 'Run test file' })

vim.keymap.set('n', '<leader>xw', function()
  local watch_cmd = vim.tbl_get(vim.g.test_commands, 'watch')
  if not watch_cmd then
    return notify('No test command for watch')
  end
  return run_file(watch_cmd)
end, { desc = 'Watch test file' })

vim.keymap.set('n', '<leader>xi', function()
  local single_test = vim.tbl_get(vim.g.test_commands, 'single_test')
  if not single_test then
    return notify('No test command for single test')
  end

  local cmd = single_test
  if type(single_test) == 'function' then
    cmd = single_test()
  end

  if not cmd then
    return notify('No tests found for single test')
  end

  return run_file(cmd)
end, { desc = 'Run single test' })

vim.keymap.set('n', '<leader>xt', function()
  local all_cmd = vim.tbl_get(vim.g.test_commands, 'all')
  if not all_cmd then
    return notify('No test command for all tests')
  end
  return exec(all_cmd)
end, { desc = 'Run all tests' })

vim.keymap.set('n', '<leader>xf', function()
  local bufnr, win_id = get_terminal_bufnr()
  if not bufnr then
    return
  end
  vim.api.nvim_win_set_config(win_id, { hide = false })
  if vim.api.nvim_get_current_buf() == bufnr then
    return vim.cmd.wincmd('p')
  end
  vim.api.nvim_set_current_win(win_id)
end, { desc = 'Focus test window' })

vim.keymap.set('n', '<leader>X', function()
  local bufnr, winid = get_terminal_bufnr()
  if not bufnr then
    return
  end
  local config = vim.api.nvim_win_get_config(winid)
  vim.api.nvim_win_set_config(winid, { hide = not config.hide })
  if vim.api.nvim_get_current_buf() == bufnr then
    vim.cmd('wincmd p')
  end
end, { desc = 'Focus test window' })

vim.api.nvim_create_autocmd('VimResized', {
  group = augroup,
  callback = function()
    local bufnr, win = get_terminal_bufnr()
    if not bufnr then
      return
    end
    local config = vim.api.nvim_win_get_config(win)

    if config.hide then
      return
    end

    vim.api.nvim_win_set_config(win, win_config())
  end,
})
