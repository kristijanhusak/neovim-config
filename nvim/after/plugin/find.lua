local function find(opts)
  local path = vim.loop.fs_stat(opts.args)
  if path then
    return vim.cmd('edit ' .. opts.args)
  end
  vim.notify('File not found: ' .. opts.args, vim.log.levels.ERROR)
end

local function parse_results(items)
  return { unpack(items, 1, vim.o.lines / 2) }
end

local function complete(arg_lead, cmdline, cursor_pos)
  local result = vim.system({ 'rg', '--files' }, { text = false }):wait()

  if result and result.code == 0 then
    local files = vim.split(result.stdout, '\n')
    if vim.trim(arg_lead or '') == '' then
      return parse_results(files)
    end
    return parse_results(vim.fn.matchfuzzy(files, arg_lead))
  end

  return {}
end

vim.api.nvim_create_user_command('Find', find, { force = true, nargs = '?', complete = complete })
