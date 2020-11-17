require'gitsigns'.setup({
  signs = {
    add          = {hl = 'diffAdded', text = '┃'},
    change       = {hl = 'PreProc', text = '┃'},
    delete       = {hl = 'diffRemoved', text = '_'},
    topdelete    = {hl = 'diffRemoved', text = '‾'},
    changedelete = {hl = 'PreProc', text = '┃'},
  },
})
