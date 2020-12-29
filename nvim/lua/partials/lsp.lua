local nvim_lsp = require'lspconfig'

vim.cmd [[augroup vimrc_lsp ]]
  vim.cmd [[autocmd!]]
  vim.cmd [[autocmd CursorHold * lua vim.lsp.diagnostic.show_line_diagnostics()]]
vim.cmd [[augroup END]]

nvim_lsp.diagnosticls.setup({
  filetypes={
    'javascript',
    'typescript',
    'javascriptreact',
    'typescriptreact',
  },
  init_options = {
    linters = {
      eslint = {
        command = './node_modules/.bin/eslint',
        rootPatterns = { '.git' },
        debounce = 100,
        args = {
          '--stdin',
          '--stdin-filename',
          '%filepath',
          '--format',
          'json'
        },
        sourceName = 'eslint',
        parseJson = {
          errorsRoot = '[0].messages',
          line = 'line',
          column = 'column',
          endLine = 'endLine',
          endColumn = 'endColumn',
          message = '${message} [${ruleId}]',
          security = 'severity'
        },
        securities = {
          ['1'] = 'warning',
          ['2'] = 'error',
        },
      },
    },
    filetypes = {
      javascript = 'eslint',
      typescript = 'eslint',
      javascriptreact = 'eslint',
      typescriptreact = 'eslint',
    },
    formatters = {
      prettierEslint = {
        command = './node_modules/.bin/prettier-eslint',
        args = {
          '--stdin',
          '--single-quote',
          '--print-width',
          '120',
        },
        rootPatterns = { '.git' },
      },
    },
    formatFiletypes = {
      javascript = 'prettierEslint',
      typescript = 'prettierEslint',
      javascriptreact = 'prettierEslint',
      typescriptreact = 'prettierEslint'
    },
  }
})
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

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, { virtual_text = false }
)

vim.cmd[[sign define LspDiagnosticsSignError text= texthl=LspDiagnosticsSignError linehl= numhl=]]
vim.cmd[[sign define LspDiagnosticsSignWarning text= texthl=LspDiagnosticsSignWarning linehl= numhl=]]
vim.cmd[[sign define LspDiagnosticsSignInformation text= texthl=LspDiagnosticsSignInformation linehl= numhl=]]
vim.cmd[[sign define LspDiagnosticsSignHint text= texthl=LspDiagnosticsSignHint linehl= numhl=]]
