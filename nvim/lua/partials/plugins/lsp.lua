local diagnostic_ns = vim.api.nvim_create_namespace('lsp_diagnostics')
local lsp_group = vim.api.nvim_create_augroup('vimrc_lsp', { clear = true })

local setup = {}

local diagnostic_icons = {
  [vim.diagnostic.severity.ERROR] = ' ',
  [vim.diagnostic.severity.WARN] = ' ',
  [vim.diagnostic.severity.INFO] = ' ',
  [vim.diagnostic.severity.HINT] = ' ',
}

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
    { 'pmizio/typescript-tools.nvim' },
    { 'SmiteshP/nvim-navic' },
    { 'williamboman/mason.nvim' },
    { 'williamboman/mason-lspconfig.nvim' },
    { 'folke/neodev.nvim' },
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
    signs = {
      text = diagnostic_icons
    },
  })

  vim.lsp.handlers['textDocument/hover'] =
    vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded', focusable = false })

  vim.lsp.handlers['textDocument/signatureHelp'] =
    vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'single', focusable = false, silent = true })
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
      fname_width = (vim.o.columns * 0.4),
    })
  end, opts)
  vim.keymap.set('n', '<leader>lc', vim.lsp.buf.declaration, opts)
  vim.keymap.set('n', '<leader>lg', function()
    return require('telescope.builtin').lsp_implementations()
  end, opts)
  vim.keymap.set('n', '<Space>', vim.lsp.buf.hover, { silent = true, buffer = true })
  vim.keymap.set({ 'n', 'v' }, '<leader>lf', function()
    return require('conform').format({
      lsp_fallback = true,
      timeout_ms = 5000,
    })
  end, opts)
  vim.keymap.set('n', '<leader>li', vim.lsp.buf.incoming_calls, opts)
  vim.keymap.set('n', '<leader>lh', function()
    vim.lsp.inlay_hint(0, nil)
  end, opts)
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
  vim.keymap.set('n', '[d', function()
    return vim.diagnostic.goto_prev({ float = false })
  end, opts)
  vim.keymap.set('n', ']d', function()
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
      'gopls',
      'lua_ls',
    },
  })
end

function setup.servers()
  local nvim_lsp = require('lspconfig')

  local function lsp_setup(opts)
    opts = opts or {}
    return vim.tbl_deep_extend('force', {
      on_attach = function(client, bufnr)
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
  nvim_lsp.eslint.setup(lsp_setup({
    settings = {
      packageManager = 'yarn',
    },
  }))

  require('typescript-tools').setup(lsp_setup({
    disableFormatting = true,
    settings = {
      expose_as_code_action = 'all',
      tsserver_file_preferences = {
        includeInlayParameterNameHints = 'all',
        quotePreference = 'single',
        importModuleSpecifierPreference = 'relative',
      },
    },
  }))

  local runtime_path = vim.split(package.path, ';')
  table.insert(runtime_path, 'lua/?.lua')
  table.insert(runtime_path, 'lua/?/init.lua')

  require('neodev').setup()
  nvim_lsp.lua_ls.setup(lsp_setup({
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

    local virtual_text_opts = {
      prefix = function(diagnostic)
        return diagnostic_icons[diagnostic.severity]
      end or '',
    }

    if vim.fn.has('nvim-0.10.0') == 0 then
      virtual_text_opts = {
        prefix = '',
        format = function(diagnostic)
          return string.format('%s %s', diagnostic_icons[diagnostic.severity], diagnostic.message)
        end,
      }
    end

    vim.diagnostic.show(diagnostic_ns, bufnr, diagnostics, {
      virtual_text = virtual_text_opts,
      severity_sort = true,
    })
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
