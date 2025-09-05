---@class PackOpts
---@field src string The GitHub src of the plugin (e.g., 'user/repo' or full URL)
---@field name? string The GitHub path of the plugin (e.g., 'user/repo' or full URL)
---@field dependencies? (string | PackOpts)[] List of plugin dependencies
---@field config? fun(opts: PackOpts) Optional configuration function to run after loading the plugin
---@field version? string|vim.VersionRange
---@field build? string | fun(plug_data: {spec: vim.pack.Spec, path: string}) Optional build command or function to run after installation
---@field local_package? boolean is given path a local package
---@field loaded? boolean is plugin loaded

---@class PackOnEventsOpts:PackOpts
---@field event string | string[] The autocommand event to trigger loading the plugin (e.g., 'FileType', 'InsertEnter')
---@field pattern? string|string[] The pattern(s) to match for

---@class PackOnCmdOpts:PackOpts
---@field cmd string | string[] The GitHub path of the plugin (e.g., 'user/repo' or full URL)

local augroup = vim.api.nvim_create_augroup('kris_neovim_config', { clear = true })

---@type table<string, PackOpts>
local plugins = {}
---@type PackOpts[]
local install_plugins = {}
---@type PackOpts[]
local load_on_start_plugins = {}

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
        print(('Running build for %s...'):format(data.spec.name))
        if type(plugin.build) == 'string' then
          vim.cmd(plugin.build)
        elseif type(plugin.build) == 'function' then
          plugin.build(data)
        end
        print(('Finished running build for %s...'):format(data.spec.name))
      end
    end
  end,
})

---@param opts PackOpts
---@return PackOpts
local function queue_for_install(opts)
  if not opts.local_package and not vim.startswith(opts.src, 'http') then
    opts.src = ('https://github.com/%s'):format(opts.src)
  end
  if not opts.name then
    local parts = vim.split(opts.src, '/')
    opts.name = parts[#parts]
  end
  plugins[opts.name] = opts
  if opts.dependencies then
    local deps = {}
    for _, dep in ipairs(opts.dependencies) do
      if type(dep) == 'string' then
        dep = { src = dep }
      end
      table.insert(deps, queue_for_install(dep))
    end
    opts.dependencies = deps
  end
  if not opts.local_package then
    table.insert(install_plugins, opts)
  end
  return opts
end

---@param opts PackOpts
local function load_plugin(opts)
  local plugin = plugins[opts.name]
  if plugin.loaded then
    return
  end

  if plugin.dependencies then
    for _, dep in ipairs(plugin.dependencies) do
      ---@cast dep PackOpts
      load_plugin(dep)
    end
  end

  if not plugin.local_package then
    vim.cmd.packadd(plugin.name)
  else
    vim.opt.runtimepath:append(vim.fn.fnamemodify(plugin.src, ':p'))
  end

  if plugin.config then
    opts.config(plugin)
  end
  plugins[opts.name].loaded = true
end

---@param opts PackOnEventsOpts
vim.pack.on_event = function(opts)
  local plugin = queue_for_install(opts)
  vim.api.nvim_create_autocmd(opts.event, {
    group = augroup,
    pattern = opts.pattern,
    nested = true,
    once = true,
    callback = function()
      load_plugin(plugin)
    end,
  })
end

vim.pack.on_cmd = function(opts)
  local plugin = queue_for_install(opts)
  local cmds = type(opts.cmd) == 'string' and { opts.cmd } or opts.cmd

  local del_cmds = function()
    for _, cmd in ipairs(cmds) do
      vim.api.nvim_del_user_command(cmd)
    end
  end

  for _, cmd in ipairs(cmds) do
    vim.api.nvim_create_user_command(cmd, function(args)
      del_cmds()
      load_plugin(plugin)
      local mods = {}
      for _, val in ipairs(vim.split(args.mods, ' ')) do
        if val and val ~= '' then
          mods[val] = true
        end
      end
      vim.api.nvim_cmd({
        cmd = args.name,
        args = args.fargs,
        bang = args.bang,
        mods = mods,
      }, {})
    end, {
      force = true,
    })
  end
end

---@param opts PackOpts
vim.pack.on_start = function(opts)
  local plugin = queue_for_install(opts)
  table.insert(load_on_start_plugins, plugin)
end

vim.pack.status = function()
  local loaded = {}
  local not_loaded = {}
  for name, plugin in pairs(plugins) do
    if plugin.loaded then
      table.insert(loaded, name)
    else
      table.insert(not_loaded, name)
    end
  end
  vim.api.nvim_echo(
    {
      { 'LOADED:\n', 'Title' },
      { table.concat(loaded, '\n') },
      { '\nNOT LOADED:\n', 'Title' },
      { table.concat(not_loaded, '\n'), 'Comment' },
    },
    true,
    {}
  )
end

local cur_file_path = vim.fs.dirname(debug.getinfo(1, 'S').source:sub(2))
local handle = vim.loop.fs_scandir(('%s/packs'):format(cur_file_path))

if not handle then
  error('Could not scan packs directory')
end

vim.pack.on_start({ src = 'tpope/vim-repeat' })
vim.pack.on_start({ src = 'tpope/vim-sleuth' })
vim.pack.on_start({ src = 'tpope/vim-abolish' })
vim.pack.on_start({ src = 'tpope/vim-surround' })
vim.pack.on_start({ src = 'nvim-tree/nvim-web-devicons' })
vim.pack.on_start({ src = 'nvim-lua/plenary.nvim' })
vim.pack.on_start({
  src = 'folke/which-key.nvim',
  config = function()
    require('which-key').setup({
      preset = 'helix',
    })
  end,
})

while true do
  local name = vim.loop.fs_scandir_next(handle)
  if not name then
    break
  end
  require(('partials.packs.%s'):format(name:gsub('%.lua$', '')))
end

vim.pack.add(install_plugins, {
  -- Do packadd manually
  load = function() end,
})

for _, plugin in ipairs(load_on_start_plugins) do
  load_plugin(plugin)
end
