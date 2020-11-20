require'gitsigns'.setup({
  signs = {
    add          = {hl = 'GitSignAdd', text = '▌'},
    change       = {hl = 'GitSignChange', text = '▌'},
    delete       = {hl = 'GitSignRemove', text = '_'},
    topdelete    = {hl = 'GitSignRemove', text = '‾'},
    changedelete = {hl = 'GitSignChange', text = '▌'},
  },
})
