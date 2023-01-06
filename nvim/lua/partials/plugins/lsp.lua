local diagnostic_ns = vim.api.nvim_create_namespace('lsp_diagnostics')
local lsp_group = vim.api.nvim_create_augroup('vimrc_lsp', { clear = true })

local setup = {}

local lsp = {
  'neovim/nvim-lspconfig',
  dependencies = {
    { 'jose-elias-alvarez/null-ls.nvim', lazy = true },
    { 'jose-elias-alvarez/typescript.nvim', lazy = true },
    { 'SmiteshP/nvim-navic', lazy = true },
    { 'williamboman/mason.nvim', lazy = true },
    { 'williamboman/mason-lspconfig.nvim', lazy = true },
  },
  event = 'VeryLazy',
}
lsp.config = function()
  setup.configure_handlers()
  setup.mason()
  setup.servers()

  -- Re-trigger filetype autocmd to enable LSP
  -- if Neovim was opened with a file
  if vim.bo.filetype ~= '' then
    vim.cmd('doautocmd FileType ' .. vim.bo.filetype)
  end

  return lsp
end

function setup.configure_handlers()
  vim.diagnostic.config({
    virtual_text = false,
  })

  vim.lsp.handlers['textDocument/hover'] =
    vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded', focusable = false })

  vim.lsp.handlers['textDocument/signatureHelp'] =
    vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'single', focusable = false, silent = true })

  vim.cmd([[
    sign define DiagnosticSignError text= texthl=DiagnosticSignError linehl= numhl=
    sign define DiagnosticSignWarn text= texthl=DiagnosticSignWarn linehl= numhl=
    sign define DiagnosticSignInfo text= texthl=DiagnosticSignInfo linehl= numhl=
    sign define DiagnosticSignHint text= texthl=DiagnosticSignHint linehl= numhl=
  ]])
end

function setup.mappings()
  local opts = { buffer = true, silent = true }
  vim.keymap.set('n', '<leader>ld', function()
    return require('telescope.builtin').lsp_definitions()
  end, opts)
  vim.keymap.set('n', '<leader>lw', function()
    return require('telescope.builtin').lsp_type_definitions()
  end, opts)
  vim.keymap.set('n', '<leader>lu', function()
    return require('telescope.builtin').lsp_references({
      previewer = false,
      fname_width = 80,
    })
  end, opts)
  vim.keymap.set('n', '<leader>lc', vim.lsp.buf.declaration, opts)
  vim.keymap.set('n', '<leader>lg', function()
    return require('telescope.builtin').lsp_implementations()
  end, opts)
  vim.keymap.set('n', '<Space>', vim.lsp.buf.hover, { silent = true, buffer = true })
  vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format, opts)
  vim.keymap.set('v', '<leader>lf', function()
    return vim.lsp.buf.format()
  end, opts)
  vim.keymap.set('n', '<leader>li', vim.lsp.buf.incoming_calls, opts)
  vim.keymap.set('n', '<leader>lo', vim.lsp.buf.outgoing_calls, opts)
  vim.keymap.set('n', '<leader>lt', vim.lsp.buf.document_symbol, opts)
  vim.keymap.set('n', '<leader>lo', vim.lsp.buf.outgoing_calls, opts)
  vim.keymap.set('n', '<leader>le', function()
    return vim.diagnostic.open_float({ scope = 'line', show_header = false, focusable = false, border = 'rounded' })
  end, opts)
  vim.keymap.set('n', '<Leader>e', vim.diagnostic.setloclist, opts)
  vim.keymap.set('n', '<leader>lr', vim.lsp.buf.rename, opts)
  vim.keymap.set('n', '[g', function()
    return vim.diagnostic.goto_prev({ float = false })
  end, opts)
  vim.keymap.set('n', ']g', function()
    return vim.diagnostic.goto_next({ float = false })
  end, opts)
  vim.keymap.set('n', '<Leader>la', vim.lsp.buf.code_action, opts)
  vim.keymap.set('x', '<Leader>la', function()
    return vim.lsp.buf.code_action()
  end, opts)
  vim.keymap.set('i', '<C-k>', function()
    vim.lsp.buf.signature_help()
    return ''
  end, { expr = true, buffer = true })
end

function setup.mason()
  require('mason').setup({
    ui = {
      border = 'rounded',
    },
    -- Non-lsp items to install
    -- prettierd
    -- eslint_d
    -- sqlfluff
    -- sql-formatter
    -- stylua
  })
  require('mason-lspconfig').setup({
    ensure_installed = {
      'pylsp',
      'terraformls',
      'vimls',
      'tsserver',
      'intelephense',
      'gopls',
      'sumneko_lua',
    },
  })
end

function setup.servers()
  local nvim_lsp = require('lspconfig')

  local function lsp_setup(opts)
    opts = opts or {}
    return vim.tbl_deep_extend('force', {
      flags = {
        debounce_text_changes = 300,
      },
      on_attach = function(client, bufnr)
        client.server_capabilities.semanticTokensProvider = nil
        require('nvim-navic').attach(client, bufnr)
        setup.attach_to_buffer(client, bufnr)
        if opts.disableFormatting then
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
        end
      end,
    }, opts or {})
  end

  require('typescript').setup({
    server = lsp_setup({
      init_options = {
        preferences = {
          quotePreference = 'single',
        },
      },
      disableFormatting = true,
    }),
  })

  nvim_lsp.vimls.setup(lsp_setup())
  nvim_lsp.intelephense.setup(lsp_setup())
  nvim_lsp.gopls.setup(lsp_setup())
  nvim_lsp.pylsp.setup(lsp_setup())
  nvim_lsp.terraformls.setup(lsp_setup())

  local runtime_path = vim.split(package.path, ';')
  table.insert(runtime_path, 'lua/?.lua')
  table.insert(runtime_path, 'lua/?/init.lua')

  nvim_lsp.sumneko_lua.setup(lsp_setup({
    settings = {
      Lua = {
        runtime = {
          version = 'LuaJIT',
          path = runtime_path,
        },
        diagnostics = {
          globals = { 'vim', 'describe', 'it', 'before_each', 'after_each' },
        },
        workspace = {
          checkThirdParty = false,
          ignoreDir = { '.git' },
        },
        telemetry = {
          enable = false,
        },
      },
    },
    disableFormatting = true,
  }))

  local null_ls = require('null-ls')
  null_ls.setup({
    diagnostic_config = {
      virtual_text = false,
    },
    sources = {
      -- Code actions
      null_ls.builtins.code_actions.eslint_d,
      -- require('typescript.extensions.null-ls.code-actions'),

      -- Diagnostics
      null_ls.builtins.diagnostics.eslint_d,
      null_ls.builtins.diagnostics.sqlfluff.with({
        extra_args = { '--dialect', 'postgres' },
      }),

      -- Formatters
      null_ls.builtins.formatting.prettierd,
      null_ls.builtins.formatting.stylua,
      null_ls.builtins.formatting.sqlfluff.with({
        extra_args = { '--dialect', 'postgres' },
      }),
    },
  })
end

local function show_diagnostics()
  vim.schedule(function()
    local line = vim.api.nvim_win_get_cursor(0)[1] - 1
    local bufnr = vim.api.nvim_get_current_buf()
    local diagnostics = vim.diagnostic.get(bufnr, { lnum = line })
    vim.diagnostic.show(diagnostic_ns, bufnr, diagnostics, { virtual_text = true })
  end)
end

local function refresh_diagnostics()
  vim.diagnostic.setloclist({ open = false })
  show_diagnostics()
  if vim.tbl_isempty(vim.fn.getloclist(0)) then
    vim.cmd.lclose()
  end
end

function setup.attach_to_buffer(client, bufnr)
  vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
    buffer = bufnr,
    callback = show_diagnostics,
    group = lsp_group,
  })
  vim.api.nvim_create_autocmd('DiagnosticChanged', {
    buffer = bufnr,
    callback = refresh_diagnostics,
    group = lsp_group,
  })
  if
    client.server_capabilities.signatureHelpProvider
    and not vim.tbl_isempty(client.server_capabilities.signatureHelpProvider)
  then
    vim.api.nvim_create_autocmd('CursorHoldI', {
      buffer = bufnr,
      callback = function()
        vim.defer_fn(function()
          vim.lsp.buf.signature_help()
        end, 500)
      end,
      group = lsp_group,
    })
  end
  vim.opt.foldmethod = 'expr'
  vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
  setup.mappings()
end

return lsp
