local util = require'vim.lsp.util'
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

local opts = {
  height = 24,
	mode = 'editor',
	prompt = {},
	keymaps = {
		i = {
			['<C-j>'] = '<C-n>',
			['<C-k>'] = '<C-p>',
		}
	}
}

vim.g.lsp_utils_location_opts = opts
vim.g.lsp_utils_symbols_opts = opts

vim.lsp.handlers['textDocument/codeAction'] = require'lsputil.codeAction'.code_action_handler
vim.lsp.handlers['textDocument/references'] = require'lsputil.locations'.references_handler
vim.lsp.handlers['textDocument/definition'] = require'lsputil.locations'.definition_handler
vim.lsp.handlers['textDocument/declaration'] = require'lsputil.locations'.declaration_handler
vim.lsp.handlers['textDocument/typeDefinition'] = require'lsputil.locations'.typeDefinition_handler
vim.lsp.handlers['textDocument/implementation'] = require'lsputil.locations'.implementation_handler
vim.lsp.handlers['textDocument/documentSymbol'] = require'lsputil.symbols'.document_handler
vim.lsp.handlers['workspace/symbol'] = require'lsputil.symbols'.workspace_handler

vim.lsp.handlers['_typescript.rename'] = function(_, _, result)
  if not result then return end
  vim.fn.cursor(result.position.line + 1, result.position.character + 1)
  local new_name = vim.fn.input('New Name: ', vim.fn.expand('<cword>'))
  result.newName = new_name
  return vim.lsp.buf_request(0, 'textDocument/rename', result)
end

local old_range_params = vim.lsp.util.make_given_range_params
function vim.lsp.util.make_given_range_params(start_pos, end_pos)
  local params = old_range_params(start_pos, end_pos)
  local add = vim.o.selection ~= 'exclusive' and 1 or 0
  params.range['end'].character = params.range['end'].character + add
  return params
end
