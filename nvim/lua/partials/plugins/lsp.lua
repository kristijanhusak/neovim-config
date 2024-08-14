local diagnostic_ns = vim.api.nvim_create_namespace('lsp_diagnostics')
local lsp_group = vim.api.nvim_create_augroup('vimrc_lsp', { clear = true })

local setup = {}

local filetypes = {
  'vim',
  'php',
  'go',
  'python',
  'terraform',
  'lua',
  'yaml',
  'dockerfile',
  'javascript',
  'javascriptreact',
  'typescript',
  'typescriptreact',
}

local lsp = {
  'neovim/nvim-lspconfig',
  dependencies = {
    { 'yioneko/nvim-vtsls' },
    { 'SmiteshP/nvim-navic' },
    { 'williamboman/mason.nvim' },
    { 'williamboman/mason-lspconfig.nvim' },
    { 'folke/lazydev.nvim' },
    { 'stevearc/conform.nvim' },
  },
  ft = filetypes,
}
lsp.config = function()
  setup.configure_handlers()
  setup.mason()
  setup.servers()

  return lsp
end

function setup.configure_handlers()
  vim.diagnostic.config({
    virtual_text = false,
    float = {
      border = 'rounded',
      header = '',
      focusable = false,
    },
    signs = {
      text = _G.kris.diagnostic_icons,
    },
  })

  vim.lsp.handlers['textDocument/hover'] =
    vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded', focusable = false })

  vim.lsp.handlers['textDocument/signatureHelp'] =
    vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'single', focusable = false, silent = true })
end

function setup.mappings()
  ---@param desc string
  ---@return table
  local opts = function(desc)
    return { buffer = true, silent = true, desc = desc }
  end

  vim.keymap.set('n', '<C-]>', function()
    return require('telescope.builtin').lsp_definitions()
  end, opts('LSP definitions'))
  vim.keymap.set('n', '<leader>lw', function()
    return require('telescope.builtin').lsp_type_definitions()
  end, opts('LSP type definitions'))
  vim.keymap.set('n', '<Leader>t', function()
    require('telescope.builtin').lsp_document_symbols({ symbols = { 'function', 'variable', 'method' } })
  end, opts('LSP document symbols'))
  vim.keymap.set('n', '<Leader>lT', function()
    return require('telescope.builtin').lsp_dynamic_workspace_symbols()
  end)
  vim.keymap.set('n', '<leader>lu', function()
    return require('telescope.builtin').lsp_references({
      previewer = false,
      fname_width = (vim.o.columns * 0.4),
    })
  end, opts('LSP references'))
  vim.keymap.set('n', '<leader>lc', vim.lsp.buf.declaration, opts('LSP declaration'))
  vim.keymap.set('n', '<leader>lg', function()
    return require('telescope.builtin').lsp_implementations()
  end, opts('LSP implementations'))
  vim.keymap.set('n', '<Space>', vim.lsp.buf.hover, { silent = true, buffer = true })
  vim.keymap.set({ 'n', 'x' }, '<leader>lf', function()
    return require('conform').format({
      lsp_format = 'fallback',
      timeout_ms = 5000,
    })
  end, opts('LSP format'))
  vim.keymap.set('n', '<leader>li', vim.lsp.buf.incoming_calls, opts('LSP incoming calls'))
  vim.keymap.set('n', '<leader>lh', function()
    vim.lsp.inlay_hint.enable(0, not vim.lsp.inlay_hint.is_enabled())
  end, opts('LSP inlay hints'))
  vim.keymap.set('n', '<leader>lo', vim.lsp.buf.outgoing_calls, opts('LSP outgoing calls'))
  vim.keymap.set('n', '<leader>lt', vim.lsp.buf.document_symbol, opts('LSP document symbols'))
  vim.keymap.set('n', '<leader>lo', vim.lsp.buf.outgoing_calls, opts('LSP outgoing calls'))
  vim.keymap.set('n', '<Leader>e', vim.diagnostic.setloclist, opts('LSP diagnostics list'))
  vim.keymap.set('n', '<leader>lr', vim.lsp.buf.rename, opts('LSP rename'))
  vim.keymap.set('n', '<Leader>la', vim.lsp.buf.code_action, opts('LSP code action'))
  vim.keymap.set('x', '<Leader>la', function()
    return vim.lsp.buf.code_action()
  end, opts('LSP code action'))
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
    -- prettier
    -- sqlfluff
    -- sql-formatter
    -- stylua
  })
  require('mason-lspconfig').setup({
    ensure_installed = {
      'pylsp',
      'terraformls',
      'docker_compose_language_service',
      'dockerls',
      'vimls',
      'intelephense',
      'vtsls',
      'gopls',
      'lua_ls',
      'rust_analyzer',
      'eslint',
    },
  })
end

function setup.servers()
  local nvim_lsp = require('lspconfig')

  local function lsp_setup(opts)
    opts = opts or {}
    return vim.tbl_deep_extend('force', {
      on_attach = function(client, bufnr)
        if
          require('partials.utils').enable_builtin_lsp_completion()
          and client.supports_method('textDocument/completion')
        then
          vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
        end
        client.server_capabilities.semanticTokensProvider = nil
        if client.server_capabilities.documentSymbolProvider then
          require('nvim-navic').attach(client, bufnr)
        end
        setup.attach_to_buffer(client, bufnr)
        if opts.disableFormatting then
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
        end
      end,
    }, opts or {})
  end

  nvim_lsp.vimls.setup(lsp_setup())
  nvim_lsp.intelephense.setup(lsp_setup())
  nvim_lsp.gopls.setup(lsp_setup())
  nvim_lsp.pylsp.setup(lsp_setup())
  nvim_lsp.terraformls.setup(lsp_setup())
  nvim_lsp.docker_compose_language_service.setup(lsp_setup())
  nvim_lsp.dockerls.setup(lsp_setup())
  nvim_lsp.rust_analyzer.setup(lsp_setup())
  nvim_lsp.eslint.setup(lsp_setup({
    settings = {
      packageManager = 'yarn',
    },
  }))

  local vtsls_settings = {
    preferences = {
      quoteStyle = 'single',
      importModuleSpecifier = 'relative',
    },
    inlayHints = {
      parameterNames = { enabled = 'all' },
      parameterTypes = { enabled = true },
      variableTypes = { enabled = true },
      propertyDeclarationTypes = { enabled = true },
      functionLikeReturnTypes = { enabled = true },
      enumMemberValues = { enabled = true },
    },
  }
  nvim_lsp.vtsls.setup(lsp_setup({
    settings = {
      javascript = vtsls_settings,
      typescript = vtsls_settings,
      vtsls = {
        experimental = {
          completion = {
            enableServerSideFuzzyMatch = true,
          },
        },
      },
    },
    disableFormatting = true,
  }))

  require('lazydev').setup({
    library = {
      {
        path = '${3rd}/luv/library',
      },
    },
  })
  nvim_lsp.lua_ls.setup(lsp_setup({
    settings = {
      Lua = {
        diagnostics = {
          globals = { 'vim' },
        },
        workspace = {
          checkThirdParty = 'Disable',
          ignoreDir = { '.git' },
        },
        telemetry = {
          enable = false,
        },
        hint = {
          enable = true,
        },
      },
    },
    disableFormatting = true,
  }))

  require('conform').setup({
    formatters_by_ft = {
      lua = { 'stylua' },
      javascript = { 'eslint' },
      typescript = { 'eslint' },
      javascriptreact = { 'eslint' },
      typescriptreact = { 'eslint' },
      sql = { 'sqlfluff' },
    },
    formatters = {
      sqlfluff = {
        prepend_args = { '--dialect', 'postgres' },
      },
    },
  })
end

local function show_diagnostics()
  vim.schedule(function()
    local line = vim.api.nvim_win_get_cursor(0)[1] - 1
    local bufnr = vim.api.nvim_get_current_buf()
    local diagnostics = vim.diagnostic.get(bufnr, { lnum = line })

    vim.diagnostic.show(diagnostic_ns, bufnr, diagnostics, {
      virtual_text = {
        prefix = function(diagnostic)
          return _G.kris.diagnostic_icons[diagnostic.severity]
        end or '',
      },
      severity_sort = true,
    })
  end)
end

local function refresh_diagnostics()
  vim.diagnostic.setloclist({ open = false })
  show_diagnostics()
  local loclist = vim.fn.getloclist(0, { items = 0, winid = 0 })
  if vim.tbl_isempty(loclist.items) and loclist.winid > 0 then
    vim.api.nvim_win_close(loclist.winid, true)
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
  if not vim.tbl_isempty(client.server_capabilities.signatureHelpProvider or {}) then
    vim.api.nvim_create_autocmd('CursorHoldI', {
      buffer = bufnr,
      callback = function()
        local node = vim.treesitter.get_node()
        if node and (node:type() == 'arguments' or (node:parent() and node:parent():type() == 'arguments')) then
          vim.defer_fn(function()
            vim.lsp.buf.signature_help()
          end, 300)
        end
      end,
      group = lsp_group,
    })
  end
  vim.opt.foldmethod = 'expr'
  vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
  setup.mappings()
end

return lsp
