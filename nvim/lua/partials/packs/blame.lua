vim.pack.load({
  src = 'FabijanZulj/blame.nvim',
  cmd = 'BlameToggle',
  config = function()
    require('blame').setup()
  end,
})
