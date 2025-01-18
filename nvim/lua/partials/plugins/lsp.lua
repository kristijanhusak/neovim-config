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
  'ruby',
}

local preview_opts = {
  border = 'rounded',
  focusable = false,
  silent = true,
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
  setup.mason()
  setup.servers()

  return lsp
end

function setup.mappings()
  vim.diagnostic.config({
    virtual_text = false,
    float = {
      border = 'rounded',
      header = '',
      focusable = false,
    },
    signs = {
      text = _G.kris.diagnostic_icons,
      numhl = {
        [vim.diagnostic.severity.ERROR] = 'DiagnosticVirtualTextError',
        [vim.diagnostic.severity.WARN] = 'DiagnosticVirtualTextWarn',
      },
    },
    severity_sort = true,
  })

  vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, preview_opts)

  vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, preview_opts)

  ---@param desc string
  ---@return table
  local opts = function(desc)
    return { buffer = true, silent = true, desc = desc }
  end

  vim.keymap.set('n', '<leader>lg', function()
    vim.notify('Use gri', vim.log.levels.WARN)
  end, opts('LSP implementations (old)'))
  vim.keymap.set('n', 'gri', function()
    return Snacks.picker.lsp_implementations()
  end, opts('LSP implementations'))
  vim.keymap.set('n', '<C-]>', function()
    return Snacks.picker.lsp_definitions()
  end, opts('LSP definitions'))
  vim.keymap.set('n', 'gD', function()
    return Snacks.picker.lsp_definitions()
  end, opts('LSP definitions'))
  vim.keymap.set('n', '<leader>ld', function()
    return Snacks.picker.lsp_definitions()
  end, opts('LSP definitions'))
  vim.keymap.set('n', '<leader>lw', function()
    return Snacks.picker.lsp_type_definitions()
  end, opts('LSP type definitions'))
  vim.keymap.set('n', '<Leader>t', function()
    Snacks.picker.lsp_symbols()
  end, opts('LSP document symbols'))
  vim.keymap.set('n', '<leader>lu', function()
    vim.notify('Use grr', vim.log.levels.WARN)
  end, opts('LSP references (old)'))
  vim.keymap.set('n', 'grr', function()
    return Snacks.picker.lsp_references()
  end, opts('LSP references'))
  vim.keymap.set('n', '<leader>lc', vim.lsp.buf.declaration, opts('LSP declaration'))
  vim.keymap.set('n', '<Space>', function()
    return vim.lsp.buf.hover(preview_opts)
  end, { silent = true, buffer = true })
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
  vim.keymap.set('n', '<Leader>le', vim.diagnostic.setloclist, opts('LSP diagnostics list'))
  vim.keymap.set('n', '<leader>lr', function()
    vim.notify('Use grn', vim.log.levels.WARN)
  end, opts('LSP rename (old)'))
  vim.keymap.set({ 'n', 'x' }, 'grn', function()
    return vim.lsp.buf.rename()
  end, opts('LSP rename'))
  vim.keymap.set({ 'n', 'x' }, '<Leader>la', function()
    vim.notify('Use gra', vim.log.levels.WARN)
  end, opts('LSP code action (old)'))
  vim.keymap.set({ 'n', 'x' }, 'gra', function()
    vim.lsp.buf.code_action()
  end, opts('LSP code action'))
  vim.keymap.set('i', '<C-k>', function()
    vim.lsp.buf.signature_help(preview_opts)
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
      'ruby_lsp',
    },
  })
end

function setup.servers()
  local nvim_lsp = require('lspconfig')
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = vim.tbl_deep_extend('force', capabilities, {
    textDocument = {
      completion = {
        dynamicRegistration = false,
        completionItem = {
          snippetSupport = true,
          commitCharactersSupport = true,
          deprecatedSupport = true,
          preselectSupport = true,
          insertReplaceSupport = true,
          resolveSupport = {
            properties = {
              'documentation',
              'detail',
              'additionalTextEdits',
              'sortText',
              'filterText',
              'insertText',
              'textEdit',
              'insertTextFormat',
              'insertTextMode',
            },
          },
          labelDetailsSupport = true,
        },
        contextSupport = true,
        completionList = {
          itemDefaults = {
            'commitCharacters',
            'editRange',
            'insertTextFormat',
            'insertTextMode',
            'data',
          },
        },
      },
    },
  })

  local function lsp_setup(opts)
    opts = opts or {}
    return vim.tbl_deep_extend('force', {
      capabilities = capabilities,
      on_attach = function(client, bufnr)
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
  nvim_lsp.ruby_lsp.setup(lsp_setup())
  nvim_lsp.eslint.setup(lsp_setup({
    settings = {
      packageManager = 'yarn',
    },
  }))

  local vtsls_settings = {
    preferences = {
      quoteStyle = 'single',
      importModuleSpecifier = 'project-relative',
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
    },
  })
end

local function show_diagnostics()
  vim.schedule(function()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local line = cursor[1] - 1
    local col = cursor[2]
    local bufnr = vim.api.nvim_get_current_buf()
    local line_diagnostics = vim.diagnostic.get(bufnr, { lnum = line })
    local view_diagnostics = vim.tbl_filter(function(item)
      return col >= item.col and col < item.end_col
    end, line_diagnostics)

    if #view_diagnostics == 0 then
      view_diagnostics = line_diagnostics
    end

    vim.diagnostic.show(diagnostic_ns, bufnr, view_diagnostics, {
      virtual_text = {
        prefix = function(diagnostic)
          return _G.kris.diagnostic_icons[diagnostic.severity] or ''
        end,
      },
    })
  end)
end

local function refresh_diagnostics()
  vim.diagnostic.setloclist({ open = false, namespace = diagnostic_ns })
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

  if client:supports_method('textDocument/signatureHelp') then
    vim.api.nvim_create_autocmd('CursorHoldI', {
      buffer = bufnr,
      callback = function()
        local node = vim.treesitter.get_node()
        if node and (node:type() == 'arguments' or (node:parent() and node:parent():type() == 'arguments')) then
          vim.defer_fn(function()
            vim.lsp.buf.signature_help(preview_opts)
          end, 1000)
        end
      end,
      group = lsp_group,
    })
  end

  vim.opt.foldmethod = 'expr'
  if client:supports_method('textDocument/foldingRange') and vim.lsp.foldexpr then
    vim.opt.foldexpr = 'v:lua.vim.lsp.foldexpr()'
    vim.opt.foldtext = 'v:lua.vim.lsp.foldtext()'
  elseif vim.treesitter.foldexpr then
    vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    vim.opt.foldtext = ''
  else
    vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
    vim.opt.foldtext = ''
  end
  setup.mappings()
end

return lsp
