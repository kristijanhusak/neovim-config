local nvim_lsp = require'lspconfig'

nvim_lsp.tsserver.setup{}
nvim_lsp.vimls.setup{}
nvim_lsp.intelephense.setup{}
nvim_lsp.gopls.setup{}
nvim_lsp.pyls.setup{}
nvim_lsp.sumneko_lua.setup{
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

require'compe_nvim_lsp'.attach()
require'compe':register_lua_source('buffer', require'compe_buffer')
