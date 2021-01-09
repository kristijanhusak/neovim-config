local nvim_lsp = require'lspconfig'

vim.cmd [[augroup vimrc_lsp]]
  vim.cmd [[autocmd!]]
  vim.cmd [[autocmd CursorHold * lua vim.lsp.diagnostic.show_line_diagnostics()]]
  vim.cmd [[autocmd CursorHoldI * silent! lua vim.lsp.buf.signature_help()]]
vim.cmd [[augroup END]]

nvim_lsp.diagnosticls.setup({
  filetypes={
    'javascript',
    'javascriptreact',
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
      javascriptreact = 'eslint',
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
      javascriptreact = 'prettierEslint',
    },
  }
})
nvim_lsp.tsserver.setup{}
nvim_lsp.vimls.setup{}
nvim_lsp.intelephense.setup{}
nvim_lsp.gopls.setup{}
nvim_lsp.pyls.setup{}

local lua_lsp_path = '/home/kristijan/github/lua-language-server'
local lua_lsp_bin = lua_lsp_path..'/bin/Linux/lua-language-server'
nvim_lsp.sumneko_lua.setup {
  cmd = {lua_lsp_bin, '-E', lua_lsp_path..'/main.lua'};
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
        -- Setup your lua path
        path = vim.split(package.path, ';'),
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = {'vim'},
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = {
          [vim.fn.expand('$VIMRUNTIME/lua')] = true,
          [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
        },
      },
    },
  },
}

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

vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, method, params, client_id, bufnr, config)
  local client = vim.lsp.get_client_by_id(client_id)
  local is_ts = vim.tbl_contains({'typescript', 'typescriptreact'}, vim.bo.filetype)
  if client and client.name == 'tsserver' and not is_ts then return end

  return vim.lsp.diagnostic.on_publish_diagnostics(
    err, method, params, client_id, bufnr, vim.tbl_deep_extend("force", config or {}, { virtual_text = false })
  )
end

vim.cmd[[sign define LspDiagnosticsSignError text= texthl=LspDiagnosticsSignError linehl= numhl=]]
vim.cmd[[sign define LspDiagnosticsSignWarning text= texthl=LspDiagnosticsSignWarning linehl= numhl=]]
vim.cmd[[sign define LspDiagnosticsSignInformation text= texthl=LspDiagnosticsSignInformation linehl= numhl=]]
vim.cmd[[sign define LspDiagnosticsSignHint text= texthl=LspDiagnosticsSignHint linehl= numhl=]]
