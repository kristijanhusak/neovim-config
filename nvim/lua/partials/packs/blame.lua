vim.pack.on_cmd({
  src = 'FabijanZulj/blame.nvim',
  cmd = 'BlameToggle',
  config = function()
    require('blame').setup()
  end,
})
