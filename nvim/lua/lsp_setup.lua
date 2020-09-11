local completion = require'completion'.on_attach
local nvim_lsp = require'nvim_lsp'
require'treesitter_setup'

nvim_lsp.tsserver.setup{on_attach=completion}
nvim_lsp.vimls.setup{on_attach=completion}
nvim_lsp.intelephense.setup{on_attach=completion}
nvim_lsp.gopls.setup{on_attach=completion}
nvim_lsp.pyls.setup{on_attach=completion}
nvim_lsp.sumneko_lua.setup{
  on_attach=completion,
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
      },
      diagnostics = {
        globals = {'vim'}
      },
      workspace = {
        library = {
          [vim.fn.expand("$VIMRUNTIME/lua")] = true,
          [vim.fn.expand("~/build/neovim/src/nvim/lua")] = true,
        }
      },
    }
  }
}
