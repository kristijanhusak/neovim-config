local completion = require'completion'.on_attach
local nvim_lsp = require'nvim_lsp'

nvim_lsp.tsserver.setup{on_attach=on_attach}
nvim_lsp.vimls.setup{on_attach=on_attach}
nvim_lsp.intelephense.setup{on_attach=on_attach}
nvim_lsp.gopls.setup{on_attach=on_attach}
nvim_lsp.pyls.setup{on_attach=on_attach}
