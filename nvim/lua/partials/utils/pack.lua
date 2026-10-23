vim.loader.enable(true)

---@class PackKey
---@field [1] string The lhs of the mapping
---@field [2] string|fun(): any The rhs of the mapping
---@field mode? string|string[] Mode(s) for the mapping (default: 'n')
---@field [string] any Any other option accepted by vim.keymap.set (desc, silent, expr, ...)

---@class PackOpts
---@field ft? string | string[] The filetype(s) to trigger loading the plugin (e.g., 'python', {'python', 'lua'})
---@field keys? PackKey[] The keys to trigger loading the plugin
---@field cmd? string | string[] The command(s) to trigger loading the plugin
---@field event? string | string[]  The autocommand event to trigger loading the plugin (e.g., 'InsertEnter')
---@field name? string The name of the plugin directory (defaults to the last part of the source)
---@field dependencies? (string | PackOpts)[] List of plugin dependencies
---@field config? fun(opts: PackOpts) Optional configuration function to run after loading the plugin
---@field version? string|vim.VersionRange
---@field build? string | fun(plug_data: {spec: vim.pack.Spec, path: string}) Optional build command or function to run after installation
---@field local_package? boolean is given path a local package
---@field loaded? boolean is plugin loaded
---@field enabled? boolean is plugin enabled
---@field priority? number The priority of the plugin (higher numbers load first)
---@field src? string The source URL of the plugin

local augroup = vim.api.nvim_create_augroup('kris_neovim_config', { clear = true })

local M = {}

---@type table<string, PackOpts>
local plugins = {}
---@type PackOpts[]
local install_plugins = {}
---@type PackOpts[]
local load_on_start_plugins = {}
---@type PackOpts[]
local lazy_load_on_start_plugins = {}
--- Loaded plugins that are not yet added to the lazydev workspace
---@type string[]
local lazydev_pending = {}
local lazydev_loaded = false

-- Builtin FileType groups that source ftplugin/indent/syntax files from the runtimepath
local builtin_filetype_groups = { filetypeplugin = true, filetypeindent = true, syntaxset = true }

vim.g.loaded_gzip = 1
vim.g.loaded_matchit = 1
vim.g.loaded_matchparen = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_tutor_mode_plugin = 1
vim.g.loaded_zipPlugin = 1

vim.api.nvim_create_autocmd('PackChanged', {
  group = augroup,
  callback = function(event)
    local data = event.data
    if (data.kind == 'install' or data.kind == 'update') and data.spec.name then
      local plugin = plugins[data.spec.name]
      if plugin and plugin.build and plugin.enabled then
        M.load_plugin(plugin)
        local id = ('build_%s'):format(plugin.name)
        vim.notify(('Building %s...'):format(data.spec.name), vim.log.levels.INFO, {
          title = plugin.name,
          id = id,
        })
        local ok, err = pcall(function()
          if type(plugin.build) == 'string' then
            vim.cmd(plugin.build)
          elseif type(plugin.build) == 'function' then
            plugin.build(data)
          end
        end)
        if ok then
          vim.notify(('Finished building %s.'):format(data.spec.name), vim.log.levels.INFO, {
            title = plugin.name,
            id = id,
          })
        else
          vim.notify(('Failed building %s: %s'):format(data.spec.name, err), vim.log.levels.ERROR, {
            title = plugin.name,
            id = id,
          })
        end
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

---@param value? string | string[]
---@return string[]
local function to_list(value)
  if not value then
    return {}
  end
  return type(value) == 'string' and { value } or value --[[@as string[] ]]
end

---@param a PackOpts
---@param b PackOpts
local function by_priority(a, b)
  return (a.priority or 0) > (b.priority or 0)
end

---@param name string
local function add_to_lazydev(name)
  table.insert(lazydev_pending, name)
  if not lazydev_loaded then
    return
  end
  local ok, workspace = pcall(require, 'lazydev.workspace')
  if ok then
    workspace.global():add(lazydev_pending)
    lazydev_pending = {}
  end
end

---@return table<integer, true>
local function get_filetype_augroups()
  local groups = {}
  for _, autocmd in ipairs(vim.api.nvim_get_autocmds({ event = 'FileType' })) do
    if autocmd.group then
      groups[autocmd.group] = true
    end
  end
  return groups
end

---@param opts PackOpts
---@return PackOpts
function M.queue_for_install(opts)
  if type(opts.enabled) ~= 'boolean' then
    opts.enabled = true
  end
  local src = opts[1]
  -- Only stat things that look like paths, to avoid matching 'user/repo' relative to cwd
  local stat = src:match('^[/~.]') and vim.uv.fs_stat(vim.fs.normalize(src))
  opts.local_package = stat and stat.type == 'directory' or false

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

  -- Same plugin registered multiple times (e.g. shared dependency), merge into the first registration
  local existing = plugins[opts.name]
  if existing then
    existing.enabled = existing.enabled or opts.enabled
    existing.config = existing.config or opts.config
    existing.build = existing.build or opts.build
    if opts.dependencies then
      existing.dependencies = vim.list_extend(existing.dependencies or {}, opts.dependencies)
    end
    return existing
  end

  plugins[opts.name] = opts

  if not opts.local_package then
    table.insert(install_plugins, opts)
  end
  return opts
end

--- `:packadd` after startup adds `after/` to the runtimepath, but never sources `after/plugin`.
--- During startup Neovim does that itself for everything already on the runtimepath.
---@param plugin PackOpts
local function source_after_plugin(plugin)
  if vim.v.vim_did_enter == 0 then
    return
  end
  vim.cmd.runtime({ ('pack/*/opt/%s/after/plugin/**/*.{vim,lua}'):format(plugin.name), bang = true })
end

---@param opts PackOpts
function M.load_plugin(opts)
  local plugin = plugins[opts.name]

  if not plugin or plugin.loaded or not plugin.enabled then
    return
  end

  -- Mark early to avoid infinite recursion on circular dependencies
  -- and to not retry the whole load if config throws
  plugin.loaded = true

  if plugin.dependencies then
    for _, dep in ipairs(plugin.dependencies) do
      ---@cast dep PackOpts
      M.load_plugin(dep)
    end
  end

  if plugin.local_package then
    local plugin_path = vim.fs.joinpath(M.get_local_plug_dir(), plugin.name)
    if not vim.uv.fs_lstat(plugin_path) then
      vim.fn.mkdir(M.get_local_plug_dir(), 'p')
      vim.uv.fs_symlink(plugin.src, plugin_path, { symbolic = true })
    end
  end

  vim.cmd.packadd(plugin.name)
  source_after_plugin(plugin)

  if plugin.name == 'lazydev.nvim' then
    lazydev_loaded = true
  end
  add_to_lazydev(plugin.name)

  if plugin.config then
    plugin.config(plugin)
  end
end

---@param opts PackOpts
---@param plugin PackOpts
function M.on_cmd(opts, plugin)
  local cmds = to_list(opts.cmd)

  ---@param current_cmd string
  local load = function(current_cmd)
    if plugins[plugin.name].loaded then
      -- Plugin was loaded through another trigger, other stubs might already be replaced by real commands
      pcall(vim.api.nvim_del_user_command, current_cmd)
      return
    end
    for _, cmd in ipairs(cmds) do
      pcall(vim.api.nvim_del_user_command, cmd)
    end
    M.load_plugin(plugin)
  end

  for _, cmd in ipairs(cmds) do
    vim.api.nvim_create_user_command(cmd, function(args)
      load(cmd)
      local range = ''
      if args.range == 1 then
        range = tostring(args.line1)
      elseif args.range == 2 then
        range = ('%d,%d'):format(args.line1, args.line2)
      end
      vim.cmd(('%s %s%s%s %s'):format(args.mods or '', range, cmd, args.bang and '!' or '', args.args))
    end, {
      bang = true,
      range = true,
      nargs = '*',
      complete = function(_, line)
        load(cmd)
        return vim.fn.getcompletion(line, 'cmdline')
      end,
    })
  end
end

---@param opts PackOpts
---@param plugin PackOpts
function M.on_keys(opts, plugin)
  for _, keymap in ipairs(opts.keys) do
    local lhs = keymap[1]
    local rhs = keymap[2]
    local key_opts = {}
    for key, value in pairs(keymap) do
      if type(key) == 'string' and key ~= 'mode' then
        key_opts[key] = value
      end
    end
    vim.keymap.set(keymap.mode or 'n', lhs, function()
      M.load_plugin(plugin)
      if type(rhs) == 'function' then
        return rhs()
      end
      if key_opts.expr then
        return rhs
      end
      vim.api.nvim_feedkeys(vim.keycode(rhs), key_opts.remap and 'm' or 'n', false)
    end, key_opts)
  end
end

---@param opts PackOpts
vim.pack.load = function(opts)
  local plugin = M.queue_for_install(opts)
  if not opts.enabled then
    return
  end
  local events = vim.tbl_filter(function(event)
    return event ~= 'VeryLazy'
  end, to_list(opts.event))
  local very_lazy = #events ~= #to_list(opts.event)
  local load_on_start = not (opts.ft or #events > 0 or opts.keys or opts.cmd)

  if opts.ft then
    vim.api.nvim_create_autocmd('FileType', {
      group = augroup,
      pattern = opts.ft,
      nested = true,
      once = true,
      callback = function(event)
        local groups_before = get_filetype_augroups()
        M.load_plugin(plugin)
        -- Re-trigger only the FileType autocmds added by the plugin, plus the builtin ones
        -- that source ftplugin/indent/syntax files from the newly added runtimepath entry
        local groups = {}
        for _, autocmd in ipairs(vim.api.nvim_get_autocmds({ event = 'FileType' })) do
          if autocmd.group and (not groups_before[autocmd.group] or builtin_filetype_groups[autocmd.group_name]) then
            groups[autocmd.group] = true
          end
        end
        if not vim.api.nvim_buf_is_valid(event.buf) then
          return
        end
        vim.api.nvim_buf_call(event.buf, function()
          for group in pairs(groups) do
            vim.api.nvim_exec_autocmds('FileType', { group = group, pattern = event.match, modeline = false })
          end
        end)
      end,
    })
  end
  if #events > 0 then
    vim.api.nvim_create_autocmd(events, {
      group = augroup,
      nested = true,
      once = true,
      callback = function()
        M.load_plugin(plugin)
      end,
    })
  end

  if opts.cmd then
    M.on_cmd(opts, plugin)
  end

  if opts.keys then
    M.on_keys(opts, plugin)
  end

  if very_lazy then
    table.insert(lazy_load_on_start_plugins, plugin)
  elseif load_on_start then
    table.insert(load_on_start_plugins, plugin)
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
    { 'Press "u" to update, "c" to clean, "q" to close', '' },
    vim.list_extend(vim.list_extend(loaded, not_loaded), disabled)
  )

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, all_lines)
  vim.api.nvim_set_option_value('modifiable', false, { buf = buf })
  vim.api.nvim_set_option_value('bufhidden', 'wipe', { buf = buf })
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
  local close = function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end
  vim.keymap.set('n', 'q', close, { buffer = buf, silent = true, desc = 'Close pack status window', nowait = true })
  vim.keymap.set('n', 'u', function()
    close()
    vim.pack.update()
  end, { buffer = buf, silent = true, desc = 'Close pack status window and run update', nowait = true })

  vim.keymap.set('n', 'c', function()
    close()
    vim.pack.clean()
  end, { buffer = buf, silent = true, desc = 'Close pack status window and run clean', nowait = true })

  vim.api.nvim_create_autocmd('BufLeave', {
    group = augroup,
    buffer = buf,
    once = true,
    callback = function()
      -- Defer so it doesn't run while the window is already being closed
      vim.schedule(close)
    end,
  })
end

vim.pack.delete = function()
  local all_plugins = vim
    .iter(vim.fs.dir(M.get_plug_dir()))
    :map(function(name)
      return name
    end)
    :totable()

  vim.ui.select(all_plugins, {
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

vim.pack.clean = function()
  local all_plugins = vim.fs.dir(M.get_plug_dir())
  local has_plugins_to_delete = false
  for plugin in all_plugins do
    if not plugins[plugin] then
      if vim.fn.confirm('Delete plugin ' .. plugin .. '?', '&Yes\n&No') == 1 then
        vim.pack.del({ plugin })
        has_plugins_to_delete = true
      end
    end
  end

  if not has_plugins_to_delete then
    vim.notify('No plugins to clean', vim.log.levels.INFO, {
      title = 'Pack Clean',
    })
  end
end

vim.pack.init = function()
  vim.pack.add(install_plugins, {
    -- Do packadd manually
    load = function() end,
  })

  table.sort(load_on_start_plugins, by_priority)
  table.sort(lazy_load_on_start_plugins, by_priority)

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

local cmds = { 'status', 'update', 'delete', 'clean' }
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
