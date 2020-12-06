require'gitsigns'.setup({
  signs = {
    add          = {hl = 'diffAdded', text = '▌'},
    change       = {hl = 'diffChanged', text = '▌'},
    delete       = {hl = 'diffRemoved', text = '_'},
    topdelete    = {hl = 'diffRemoved', text = '‾'},
    changedelete = {hl = 'diffChanged', text = '▌'},
  },
})
