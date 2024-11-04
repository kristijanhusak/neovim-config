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

local function get_filenames()
  local executables = {
    {
      name = 'rg',
      cmd = { 'rg', '--files' },
    },
    {
      name = 'find',
      cmd = { 'find', '.', '-type', 'f' },
    },
  }

  for _, exec in ipairs(executables) do
    if vim.fn.executable(exec.name) > 0 then
      local result = vim.system(exec.cmd, { text = false }):wait()
      if result and result.code == 0 then
        return vim.split(result.stdout, '\n')
      end
    end
  end

  return vim.fn.glob('**', false, true)
end

local function complete(arg_lead)
  local files = get_filenames()

  if vim.trim(arg_lead or '') == '' then
    return parse_results(files)
  end
  return parse_results(vim.fn.matchfuzzy(files, arg_lead))
end

vim.api.nvim_create_user_command('Find', find, { force = true, nargs = '?', complete = complete })
_G.kris.findexpr = function()
  return complete(vim.v.fname)
end

if vim.fn.exists('&findfunc') > 0 then
  vim.o.findfunc = 'v:lua.kris.findexpr()'
end
