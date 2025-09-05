vim.pack.on_event({
  src = 'windwp/nvim-ts-autotag',
  event = 'FileType',
  pattern = {
    'html',
    'javascriptreact',
    'typescriptreact',
    'svelte',
    'vue',
    'tsx',
    'jsx',
    'markdown',
    'handlebars',
    'hbs',
  },
  config = function()
    require('nvim-ts-autotag').setup()
  end,
})
