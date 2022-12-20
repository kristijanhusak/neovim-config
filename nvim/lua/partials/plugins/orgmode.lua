local orgmode = {
  'nvim-orgmode/orgmode',
  requires = {
    'akinsho/org-bullets.nvim',
  },
  config = function()
    require('orgmode').setup(require('partials.orgmode_config'))
    require('org-bullets').setup({
      concealcursor = true,
      symbols = {
        checkboxes = {
          half = { '', 'OrgTSCheckboxHalfChecked' },
          done = { '✓', 'OrgDone' },
          todo = { ' ', 'OrgTODO' },
        },
      },
    })
  end,
}

return orgmode
