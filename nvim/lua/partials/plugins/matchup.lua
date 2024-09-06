return {
  'andymass/vim-matchup',
  event = 'VeryLazy',
  enabled = function()
    -- TODO: Remove this once https://github.com/andymass/vim-matchup/pull/358 is merged
    return vim.fn.has('nvim-0.11') == 0
  end,
  init = function()
    vim.g.matchup_matchparen_status_offscreen = 0
    vim.g.matchup_matchparen_nomode = 'ivV'
    vim.g.matchup_matchparen_deferred = 100
  end,
}
