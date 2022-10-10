local matchup = {
  install = function(packager)
    return packager.add('andymass/vim-matchup')
  end,
}
matchup.setup = function()
  vim.g.matchup_matchparen_status_offscreen = 0
  vim.g.matchup_matchparen_nomode = 'ivV'
  vim.g.matchup_matchparen_deferred = 100

  return matchup
end

return matchup
