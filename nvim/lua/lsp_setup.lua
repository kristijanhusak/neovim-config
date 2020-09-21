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

local custom_symbol_callback = function(_, _, result, _, bufnr)
  if not result or vim.tbl_isempty(result) then return end

  local items = vim.lsp.util.symbols_to_items(result, bufnr)
  local items_by_name = {}
  for _, item in ipairs(items) do
    items_by_name[item.text] = item
  end

  local opts = vim.fn['fzf#wrap']({
      source = vim.tbl_keys(items_by_name),
      sink = function() end,
      options = {'--prompt', 'Symbol > '},
    })
  opts.sink = function(item)
    local selected = items_by_name[item]
    vim.fn.cursor(selected.lnum, selected.col)
  end
  vim.fn['fzf#run'](opts)
end

vim.lsp.callbacks['textDocument/documentSymbol'] = custom_symbol_callback
vim.lsp.callbacks['workspace/symbol'] = custom_symbol_callback

