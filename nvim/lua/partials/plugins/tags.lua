return {
  'ludovicchabant/vim-gutentags',
  event = 'VeryLazy',
  init = function ()
    vim.g.gutentags_project_root = {'package.json', 'tsconfig.json', 'jsconfig.json'}
  end
}
