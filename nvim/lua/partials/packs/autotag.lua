vim.pack.load({
  src = 'windwp/nvim-ts-autotag',
  ft = {
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
