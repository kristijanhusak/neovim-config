local lsp = {}
local nvim_lsp = require('lspconfig')
local utils = require('partials/utils')
local diagnostic_ns = vim.api.nvim_create_namespace('lsp_diagnostics')

local filetypes = {
  'javascript',
  'javascriptreact',
  'typescript',
  'typescriptreact',
  'lua',
  'go',
  'vim',
  'php',
  'python',
}

vim.cmd([[augroup vimrc_lsp]])
vim.cmd([[autocmd!]])
vim.cmd(string.format('autocmd FileType %s call v:lua.kris.lsp.setup()', table.concat(filetypes, ',')))
vim.cmd([[augroup END]])

function lsp.setup()
  vim.cmd([[autocmd CursorHold,CursorHoldI <buffer> lua kris.lsp.show_diagnostics()]])
  vim.cmd([[autocmd DiagnosticChanged <buffer> lua kris.lsp.refresh_diagnostics()]])
  vim.cmd([[autocmd CursorHoldI <buffer> lua vim.lsp.buf.signature_help()]])
end

local function init_setup(opts)
  return vim.tbl_deep_extend('force', {
    flags = {
      debounce_text_changes = 300,
    },
  }, opts or {})
end

function lsp.setup_diagnosticls(init_opts)
  nvim_lsp.diagnosticls.setup(init_setup({
    filetypes = {
      'javascript',
      'javascriptreact',
      'lua',
    },
    init_options = vim.tbl_deep_extend('force', {
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
            'json',
          },
          sourceName = 'eslint',
          parseJson = {
            errorsRoot = '[0].messages',
            line = 'line',
            column = 'column',
            endLine = 'endLine',
            endColumn = 'endColumn',
            message = '${message} [${ruleId}]',
            security = 'severity',
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
            '--stdin-filepath',
            '%filepath',
            '--single-quote',
            '--print-width',
            '120',
          },
          rootPatterns = { '.git' },
        },
        stylua = {
          command = 'stylua',
          args = {
            '--search-parent-directories',
            '--stdin-filepath',
            '%filepath',
            '-',
          },
        },
      },
      formatFiletypes = {
        javascript = 'prettierEslint',
        javascriptreact = 'prettierEslint',
        lua = 'stylua',
      },
    }, init_opts or {}),
  }))
end

lsp.setup_diagnosticls()
nvim_lsp.tsserver.setup(init_setup({
  init_options = {
    preferences = {
      quotePreference = 'single',
    },
  },
  commands = {
    OrganizeImports = {
      function()
        vim.lsp.buf_request_sync(0, 'workspace/executeCommand', {
          command = '_typescript.organizeImports',
          arguments = { vim.api.nvim_buf_get_name(0) },
        }, 5000)
      end,
      description = 'Organize imports',
    },
  },
}))
nvim_lsp.vimls.setup(init_setup())
nvim_lsp.intelephense.setup(init_setup())
nvim_lsp.gopls.setup(init_setup())
nvim_lsp.pyright.setup(init_setup())
local lua_lsp_path = '/home/kristijan/github/lua-language-server'
local lua_lsp_bin = lua_lsp_path .. '/bin/Linux/lua-language-server'
nvim_lsp.sumneko_lua.setup(require('lua-dev').setup({
  lspconfig = init_setup({
    cmd = { lua_lsp_bin, '-E', lua_lsp_path .. '/main.lua' },
    settings = {
      Lua = {
        diagnostics = {
          globals = { 'vim', 'describe', 'it', 'before_each', 'after_each' },
        },
      },
    },
  }),
}))

vim.lsp.handlers['_typescript.rename'] = function(_, result)
  if not result then
    return
  end
  vim.fn.cursor(result.position.line + 1, result.position.character + 2)
  vim.api.nvim_feedkeys(utils.esc('<Esc>'), 'v', true)
  vim.lsp.buf.rename()
  return {}
end

vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded', focusable = false })

vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics,
  { virtual_text = false }
)

vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(
  vim.lsp.handlers.signature_help,
  { border = 'single', focusable = false }
)

local custom_symbol_callback = function(_, result, ctx)
  if not result or vim.tbl_isempty(result) then
    return
  end

  local items = vim.lsp.util.symbols_to_items(result, ctx.bufnr)
  local items_by_name = {}
  for _, item in ipairs(items) do
    items_by_name[item.text] = item
  end

  local opts = vim.fn['fzf#wrap']({
    source = vim.tbl_keys(items_by_name),
    sink = function() end,
    options = { '--prompt', 'Symbol > ' },
  })
  opts.sink = function(item)
    local selected = items_by_name[item]
    vim.fn.cursor(selected.lnum, selected.col)
  end
  vim.fn['fzf#run'](opts)
end

vim.lsp.handlers['textDocument/documentSymbol'] = custom_symbol_callback
vim.lsp.handlers['workspace/symbol'] = custom_symbol_callback

function lsp.show_diagnostics()
  vim.schedule(function()
    local line = vim.api.nvim_win_get_cursor(0)[1] - 1
    local bufnr = vim.api.nvim_get_current_buf()
    local diagnostics = vim.diagnostic.get(bufnr, { lnum = line })
    vim.diagnostic.show(diagnostic_ns, bufnr, diagnostics, { virtual_text = true })
  end)
end

function lsp.tag_signature(word)
  local content = {}
  for _, item in ipairs(vim.fn.taglist('^' .. word .. '$')) do
    if item.kind == 'm' then
      table.insert(
        content,
        string.format('%s - %s', item.cmd:match('%([^%)]*%)'), vim.fn.fnamemodify(item.filename, ':t:r'))
      )
    end
  end

  if not vim.tbl_isempty(content) then
    vim.lsp.util.open_floating_preview(content, vim.lsp.util.try_trim_markdown_code_blocks(content), {
      border = 'rounded',
      focusable = false,
    })
    return true
  end

  return false
end

function lsp.refresh_diagnostics()
  vim.diagnostic.setloclist({ open = false })
  lsp.show_diagnostics()
  if vim.tbl_isempty(vim.fn.getloclist(0)) then
    vim.cmd([[lclose]])
  end
end

utils.keymap('n', '<leader>ld', '<cmd>lua vim.lsp.buf.definition()<CR>')
utils.keymap('n', '<leader>lu', '<cmd>lua vim.lsp.buf.references()<CR>')
utils.keymap('n', '<leader>lc', '<cmd>lua vim.lsp.buf.declaration()<CR>')
utils.keymap('n', '<leader>lg', '<cmd>lua vim.lsp.buf.implementation()<CR>')
utils.keymap('n', '<leader>lh', '<cmd>lua vim.lsp.buf.hover()<CR>')
utils.keymap('n', '<leader>lH', '<cmd>lua kris.lsp.tag_signature(vim.fn.expand("<cword>"))<CR>')
utils.keymap('n', '<leader>lf', '<cmd>lua vim.lsp.buf.formatting()<CR>')
utils.keymap('v', '<leader>lf', ':<C-u>call v:lua.vim.lsp.buf.range_formatting()<CR>')
utils.keymap('n', '<leader>li', '<cmd>lua vim.lsp.buf.incoming_calls()<CR>')
utils.keymap('n', '<leader>lo', '<cmd>lua vim.lsp.buf.outgoing_calls()<CR>')
utils.keymap('n', '<leader>lt', '<cmd>lua vim.lsp.buf.document_symbol()<CR>')
utils.keymap('n', '<leader>lo', '<cmd>lua vim.lsp.buf.outgoing_calls()<CR>')
utils.keymap(
  'n',
  '<leader>le',
  '<cmd>lua vim.diagnostic.open_float(nil, { scope = "line", show_header = false, focusable = false, border = "rounded" })<CR>'
)
utils.keymap('n', '<Leader>e', '<cmd>lua vim.diagnostic.setloclist()<CR>')
utils.keymap('n', '<leader>lr', '<cmd>lua vim.lsp.buf.rename()<CR>')
utils.keymap('n', '[g', '<cmd>lua vim.diagnostic.goto_prev({ float = false })<CR>')
utils.keymap('n', ']g', '<cmd>lua vim.diagnostic.goto_next({ float = false })<CR>')
utils.keymap('n', '<Leader>la', '<cmd>lua vim.lsp.buf.code_action()<CR>')
utils.keymap('v', '<Leader>la', ':<C-u>lua vim.lsp.buf.range_code_action()<CR>')

vim.cmd([[
  sign define DiagnosticSignError text= texthl=DiagnosticSignError linehl= numhl=
  sign define DiagnosticSignWarn text= texthl=DiagnosticSignWarn linehl= numhl=
  sign define DiagnosticSignInfo text= texthl=DiagnosticSignInfo linehl= numhl=
  sign define DiagnosticSignHint text= texthl=DiagnosticSignHint linehl= numhl=
]])

_G.kris.lsp = lsp
