vim.loader.enable(true)
local cur_file_dir = vim.fs.dirname(debug.getinfo(1, 'S').source:sub(2))

---@class PackOpts
---@field ft? string | string[] The filetype(s) to trigger loading the plugin (e.g., 'python', {'python', 'lua'})
---@field keys? [string|string[],string,fun(),table][] The keys to Trigger loading the plugin
---@field cmd? string | string[] The GitHub path of the plugin (e.g., 'user/repo' or full URL)
---@field event? string | string[]  The autocommand event to trigger loading the plugin (e.g., 'InsertEnter')
---@field name? string The GitHub path of the plugin (e.g., 'user/repo' or full URL)
---@field dependencies? (string | PackOpts)[] List of plugin dependencies
---@field config? fun(opts: PackOpts) Optional configuration function to run after loading the plugin
---@field version? string|vim.VersionRange
---@field build? string | fun(plug_data: {spec: vim.pack.Spec, path: string}) Optional build command or function to run after installation
---@field local_package? boolean is given path a local package
---@field loaded? boolean is plugin loaded
---@field enabled? boolean is plugin enabled

local augroup = vim.api.nvim_create_augroup('kris_neovim_config', { clear = true })
local lazydev_workspace = nil

local M = {}

---@type table<string, PackOpts>
local plugins = {}
---@type PackOpts[]
local install_plugins = {}
---@type PackOpts[]
local load_on_start_plugins = {}
---@type PackOpts[]
local lazy_load_on_start_plugins = {}

vim.g.loaded_gzip = 1
vim.g.loaded_matchit = 1
vim.g.loaded_matchparen = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_tutor_mode_plugin = 1
vim.g.loaded_zipPlugin = 1

local home = os.getenv('HOME')
package.path = ('%s;%s/.luarocks/share/lua/5.1/?.lua;%s/.luarocks/share/lua/5.1/?/init.lua'):format(
  package.path,
  home,
  home
)
package.cpath = ('%s;%s/.luarocks/lib/lua/5.1/?.so'):format(package.cpath, home)

vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(event)
    local data = event.data
    if (data.kind == 'install' or data.kind == 'update') and data.spec.name then
      local plugin = plugins[data.spec.name]
      if plugin and plugin.build then
        M.load_plugin(plugin)
        local id = ('build_%s'):format(plugin.name)
        vim.notify(('Building %s...'):format(data.spec.name), vim.log.levels.INFO, {
          title = plugin.name,
          id = id,
        })
        if type(plugin.build) == 'string' then
          vim.cmd(plugin.build)
        elseif type(plugin.build) == 'function' then
          plugin.build(data)
        end
        vim.notify(('Finished building %s.'):format(data.spec.name), vim.log.levels.INFO, {
          title = plugin.name,
          id = id,
        })
      end
    end
  end,
})

function M.get_plug_dir()
  return vim.fs.joinpath(vim.fn.stdpath('data'), 'site', 'pack', 'core', 'opt')
end

function M.get_local_plug_dir()
  return vim.fs.joinpath(vim.fn.stdpath('data'), 'site', 'pack', 'local', 'opt')
end

---@param opts PackOpts
---@return PackOpts
function M.queue_for_install(opts)
  if type(opts.enabled) ~= 'boolean' then
    opts.enabled = true
  end
  local src = opts[1]
  local stat = vim.uv.fs_stat(vim.fs.normalize(src))
  opts.local_package = stat and stat.type == 'directory'

  if not opts.local_package and not vim.startswith(src, 'http') then
    src = ('https://github.com/%s'):format(src)
  end
  if opts.local_package then
    src = vim.fs.normalize(src)
  end
  if not opts.name then
    local parts = vim.split(src, '/')
    opts.name = parts[#parts]
  end
  if opts.dependencies then
    local deps = {}
    for _, dep in ipairs(opts.dependencies) do
      if type(dep) == 'string' then
        dep = { dep }
      end
      if not opts.enabled then
        dep.enabled = false
      end
      table.insert(deps, M.queue_for_install(dep))
    end
    opts.dependencies = deps
  end
  opts.src = src
  plugins[opts.name] = opts

  if not opts.local_package then
    table.insert(install_plugins, opts)
  end
  return opts
end

---@param opts PackOpts
function M.load_plugin(opts)
  local plugin = plugins[opts.name]

  if plugin.loaded or not plugin.enabled then
    return
  end

  if plugin.dependencies then
    for _, dep in ipairs(plugin.dependencies) do
      ---@cast dep PackOpts
      M.load_plugin(dep)
    end
  end

  if plugin.local_package then
    local plugin_path = vim.fs.joinpath(M.get_local_plug_dir(), plugin.name)
    if not vim.uv.fs_stat(plugin_path) then
      vim.fn.mkdir(M.get_local_plug_dir(), 'p')
      vim.uv.fs_symlink(plugin[1], plugin_path, { symbolic = true })
    end
  end

  vim.cmd.packadd(plugin.name)

  if not lazydev_workspace then
    local ok, workspace = pcall(require, 'lazydev.workspace')
    if ok then
      lazydev_workspace = workspace
    end
  end

  if lazydev_workspace then
    lazydev_workspace:global():add(plugin.name)
  end

  if plugin.config then
    opts.config(plugin)
  end
  plugins[opts.name].loaded = true
end

function M.on_cmd(opts)
  local plugin = M.queue_for_install(opts)
  local cmds = type(opts.cmd) == 'string' and { opts.cmd } or opts.cmd

  local del_cmds = function()
    for _, cmd in ipairs(cmds) do
      vim.api.nvim_del_user_command(cmd)
    end
  end

  for _, cmd in ipairs(cmds) do
    vim.api.nvim_create_user_command(cmd, function(event)
      del_cmds()
      M.load_plugin(plugin)

      local command = {
        cmd = cmd,
        bang = event.bang or nil,
        mods = event.smods,
        args = event.fargs,
        count = event.count >= 0 and event.range == 0 and event.count or nil,
      }

      if event.range == 1 then
        command.range = { event.line1 }
      elseif event.range == 2 then
        command.range = { event.line1, event.line2 }
      end

      local info = vim.api.nvim_get_commands({})[cmd] or vim.api.nvim_buf_get_commands(0, {})[cmd]
      if not info then
        return
      end

      command.nargs = info.nargs
      if event.args and event.args ~= '' and info.nargs and info.nargs:find('[1?]') then
        command.args = { event.args }
      end
      vim.cmd(command)
    end, {
      bang = true,
      range = true,
      nargs = '*',
      complete = function(_, line)
        del_cmds()
        M.load_plugin(plugin)
        return vim.fn.getcompletion(line, 'cmdline')
      end,
    })
  end
end

function M.on_keys(opts)
  local plugin = M.queue_for_install(opts)
  local keys = opts.keys
  for _, keymap in ipairs(keys) do
    local lhs = keymap[1]
    local mode = keymap.mode or 'n'
    local rhs = keymap[2]
    local key_opts = {}
    if keymap.desc then
      key_opts.desc = keymap.desc
    end
    vim.keymap.set(mode, lhs, function()
      M.load_plugin(plugin)
      rhs()
    end, key_opts)
  end
end

---@param opts PackOpts
vim.pack.load = function(opts)
  local plugin = M.queue_for_install(opts)
  local very_lazy = false
  if opts.event and opts.event == 'VeryLazy' then
    very_lazy = true
    opts.event = nil
  end
  local load_on_start = not (opts.ft or opts.event or opts.keys or opts.cmd)
  if opts.ft then
    vim.api.nvim_create_autocmd('FileType', {
      group = augroup,
      pattern = opts.ft,
      nested = true,
      once = true,
      callback = function(event)
        M.load_plugin(plugin)
        vim.api.nvim_exec_autocmds('FileType', { pattern = event.match, modeline = false })
      end,
    })
  end
  if opts.event then
    vim.api.nvim_create_autocmd(opts.event, {
      group = augroup,
      nested = true,
      once = true,
      callback = function()
        M.load_plugin(plugin)
      end,
    })
  end

  if opts.cmd then
    M.on_cmd(opts)
  end

  if opts.keys then
    M.on_keys(opts)
  end

  if load_on_start then
    if very_lazy then
      table.insert(lazy_load_on_start_plugins, plugin)
    else
      table.insert(load_on_start_plugins, plugin)
    end
  end
end

vim.pack.status = function()
  local loaded = {}
  local not_loaded = {}
  local disabled = {}
  for name, plugin in pairs(plugins) do
    if plugin.loaded then
      table.insert(loaded, ('- %s'):format(name))
    elseif not plugin.enabled then
      table.insert(disabled, ('- %s'):format(name))
    else
      table.insert(not_loaded, ('- %s'):format(name))
    end
  end
  table.insert(loaded, 1, ('# Loaded (%d)'):format(#loaded))
  table.insert(loaded, '')
  table.insert(not_loaded, 1, ('# Not Loaded (%d)'):format(#not_loaded))
  table.insert(not_loaded, '')
  table.insert(disabled, 1, ('# Disabled (%d)'):format(#disabled))
  local all_lines = vim.list_extend(
    { 'Press "u" to update, "q" to close', '' },
    vim.list_extend(vim.list_extend(loaded, not_loaded), disabled)
  )

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, all_lines)
  vim.api.nvim_set_option_value('modifiable', false, { buf = buf })
  vim.api.nvim_set_option_value('filetype', 'markdown', { buf = buf })
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    border = 'rounded',
    width = math.floor(vim.o.columns / 1.5),
    height = math.floor(vim.o.lines / 1.5),
    row = math.floor(vim.o.lines / 6),
    col = math.floor(vim.o.columns / 6),
    title = 'Pack Status',
    title_pos = 'center',
  })
  vim.keymap.set('n', 'q', function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, silent = true, desc = 'Close pack status window' })
  vim.keymap.set('n', 'u', function()
    vim.api.nvim_win_close(win, true)
    vim.pack.update()
  end, { buffer = buf, silent = true, desc = 'Close pack status window and run update' })

  vim.api.nvim_create_autocmd('BufLeave', {
    group = augroup,
    buffer = buf,
    once = true,
    callback = function()
      vim.api.nvim_win_close(win, true)
    end,
  })
end

vim.pack.delete = function()
  vim.ui.select(vim.tbl_keys(plugins), {
    prompt = 'Select a plugin to delete:',
  }, function(choice)
    if not choice or choice == '' then
      return
    end
    local plugin = plugins[choice]
    if not plugin then
      vim.notify('Unknown plugin ' .. choice, vim.log.levels.ERROR, {
        title = 'Pack Delete',
      })
      return
    end
    vim.pack.del({ choice })
  end)
end

---@param dir string
vim.pack.dir = function(dir)
  local full_path = vim.fs.joinpath(cur_file_dir, '../', dir)
  local handle = vim.loop.fs_scandir(full_path)

  if not handle then
    error(('Could not scan %s directory'):format(dir))
  end

  while true do
    local name = vim.loop.fs_scandir_next(handle)
    if not name then
      break
    end
    local config = require(('partials.plugins.%s'):format(name:gsub('%.lua$', '')))
    vim.pack.load(config)
  end
  vim.pack.add(install_plugins, {
    -- Do packadd manually
    load = function() end,
  })

  for _, plugin in ipairs(load_on_start_plugins) do
    M.load_plugin(plugin)
  end

  vim.api.nvim_create_autocmd('UIEnter', {
    once = true,
    group = augroup,
    callback = function()
      vim.defer_fn(function()
        for _, plugin in ipairs(lazy_load_on_start_plugins) do
          M.load_plugin(plugin)
        end
      end, 10)
    end,
  })
end

local cmds = { 'status', 'update', 'delete' }
vim.api.nvim_create_user_command('Pack', function(args)
  if vim.trim(args.args) == '' then
    return vim.pack.status()
  end
  if vim.tbl_contains(cmds, args.args) then
    return vim.pack[args.args]()
  end

  vim.api.nvim_echo({ { ('Unknown command: %s'):format(args.args), 'ErrorMsg' } }, false, {})
end, {
  nargs = '?',
  complete = function(arg_lead)
    if not arg_lead or arg_lead == '' then
      return cmds
    end
    return vim.fn.matchfuzzy(cmds, arg_lead)
  end,
  desc = 'Pack helper command for calling vim.pack functions',
})
