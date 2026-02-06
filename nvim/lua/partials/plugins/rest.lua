local rest = {
  'rest-nvim/rest.nvim',
  event = 'VeryLazy',
  config = function()
    vim.api.nvim_create_autocmd('BufWritePost', {
      pattern = '*.http',
      command = 'Rest run',
    })
  end,
}

if not vim.g.lazy_did_setup then
  rest.build = function(data)
    vim.system({ 'luarocks', 'install', 'rest.nvim-scm-1.rockspec', '--local', '--lua-version=5.1', '--force' }, {
      cwd = data.dir or data.path,
    })
  end
end

return rest
