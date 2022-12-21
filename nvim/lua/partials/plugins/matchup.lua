local matchup = {
  'andymass/vim-matchup',
  event = 'VeryLazy',
}
matchup.init = function()
  vim.g.matchup_matchparen_status_offscreen = 0
  vim.g.matchup_matchparen_nomode = 'ivV'
  vim.g.matchup_matchparen_deferred = 100

  return matchup
end

return matchup
