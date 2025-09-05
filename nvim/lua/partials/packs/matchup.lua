vim.g.matchup_matchparen_status_offscreen = 0
vim.g.matchup_matchparen_nomode = 'ivV'
vim.g.matchup_matchparen_deferred = 100

vim.pack.load({
  src = 'andymass/vim-matchup',
  event = 'VeryLazy',
})
