vim.pack.on_start({
  src = 'rest-nvim/rest.nvim',
  build = function(data)
    vim.system({ 'luarocks', 'install', 'rest.nvim-scm-1.rockspec', '--local', '--lua-version=5.1', '--force' }, {
      cwd = data.path
    })
  end,
  config = function()
    vim.api.nvim_create_autocmd('BufWritePost', {
      pattern = '*.http',
      command = 'Rest run',
    })
  end,
})
