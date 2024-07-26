local last_cmd = nil

local function exec(cmd)
  local switch_back = vim.bo.buftype ~= 'terminal'
  for i = 1, vim.fn.winnr('$') do
    local bufnr = vim.fn.winbufnr(i)
    if vim.bo[bufnr].buftype == 'terminal' then
      vim.cmd(bufnr .. 'bw!')
      break
    end
  end
  vim.cmd([[botright vs]])
  vim.cmd(cmd)
  vim.b.last_cmd = cmd
  last_cmd = cmd
  if switch_back then
    vim.cmd.norm({ 'G', bang = true })
    vim.cmd.wincmd('p')
  end
end

local function run_file(file_cmd)
  local filename = vim.fn.expand('%:.')

  if vim.bo.buftype == 'terminal' and vim.b.last_cmd then
    return exec(vim.b.last_cmd)
  end

  local is_test_file_check = vim.tbl_get(vim.g.test_commands, 'is_test_file') or function()
    return true
  end

  local is_test_file = is_test_file_check(filename)

  if is_test_file then
    return exec(':term ' .. file_cmd:gsub('{file}', filename))
  end

  if last_cmd then
    return exec(last_cmd)
  end

  return vim.notify('Not a test file', vim.log.levels.WARN)
end

vim.keymap.set('n', '<leader>xx', function()
  local file_cmd = vim.tbl_get(vim.g.test_commands, 'file')
  if not file_cmd then
    return vim.notify('No test command for file', vim.log.levels.WARN)
  end
  return run_file(file_cmd)
end, { desc = 'Run test file' })

vim.keymap.set('n', '<leader>xw', function()
  local watch_cmd = vim.tbl_get(vim.g.test_commands, 'watch')
  if not watch_cmd then
    return vim.notify('No test command for watch', vim.log.levels.WARN)
  end
  return run_file(watch_cmd)
end, { desc = 'Watch test file' })

vim.keymap.set('n', '<leader>xi', function()
  local single_test = vim.tbl_get(vim.g.test_commands, 'single_test')
  if not single_test then
    return vim.notify('No test command for single test', vim.log.levels.WARN)
  end

  local cmd = single_test
  if type(single_test) == 'function' then
    cmd = single_test()
  end

  if not cmd then
    return vim.notify('No tests found for single test', vim.log.levels.WARN)
  end

  return run_file(cmd)
end, { desc = 'Run single test' })

vim.keymap.set('n', '<leader>xt', function()
  local all_cmd = vim.tbl_get(vim.g.test_commands, 'all')
  if not all_cmd then
    return vim.notify('No test command for all tests', vim.log.levels.WARN)
  end
  return exec(':term ' .. all_cmd)
end, { desc = 'Run all tests' })
