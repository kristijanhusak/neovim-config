local diagnostic_ns = vim.api.nvim_create_namespace('lsp_diagnostics')
local lsp_group = vim.api.nvim_create_augroup('vimrc_lsp', { clear = true })

local lsp = {}
local setup = {}

local filetypes = {
  'c',
  'cpp',
  'dockerfile',
  'go',
  'javascript',
  'javascriptreact',
  'lua',
  'php',
  'python',
  'ruby',
  'terraform',
  'typescript',
  'typescriptreact',
  'vim',
  'yaml',
}

local preview_opts = {
  border = 'rounded',
  focusable = false,
  silent = true,
}

vim.pack.load({
  src = 'neovim/nvim-lspconfig',
  dependencies = {
    'nvimtools/none-ls.nvim',
    'nvimtools/none-ls-extras.nvim',
    'SmiteshP/nvim-navic',
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'folke/lazydev.nvim',
  },
  ft = filetypes,
  config = function()
    lsp.config()
  end,
})

lsp.config = function()
  require('mason').setup({
    ui = {
      border = 'rounded',
    },
    -- Non-lsp items to install
    -- prettier
    -- sql-formatter
    -- stylua
  })

  setup.servers()

  require('mason-lspconfig').setup({
    ensure_installed = {
      'clangd',
      'docker_compose_language_service',
      'dockerls',
      'gopls',
      'intelephense',
      'lua_ls',
      'pylsp',
      'ruby_lsp',
      'rust_analyzer',
      'terraformls',
      'ts_ls',
      'vimls',
    },
  })

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

  local picker = require('partials.picker')

  ---@param desc string
  ---@return table
  local opts = function(desc)
    return { buffer = true, silent = true, desc = desc }
  end

  vim.keymap.set('n', '<leader>lg', function()
    vim.notify('Use gri', vim.log.levels.WARN)
  end, opts('LSP implementations (old)'))
  vim.keymap.set('n', 'gri', function()
    return picker.lsp_implementations()
  end, opts('LSP implementations'))
  vim.keymap.set('n', '<C-]>', function()
    return picker.lsp_definitions()
  end, opts('LSP definitions'))
  vim.keymap.set('n', 'gD', function()
    return picker.lsp_definitions()
  end, opts('LSP definitions'))
  vim.keymap.set('n', '<leader>ld', function()
    return picker.lsp_definitions()
  end, opts('LSP definitions'))
  vim.keymap.set('n', '<leader>lw', function()
    vim.notify('Use grt', vim.log.levels.WARN)
  end, opts('LSP type definitions (old)'))
  vim.keymap.set('n', 'grt', function()
    return picker.lsp_type_definitions()
  end, opts('LSP type definitions'))
  vim.keymap.set('n', '<Leader>t', function()
    picker.lsp_document_symbols()
  end, opts('LSP document symbols'))
  vim.keymap.set('n', '<leader>lu', function()
    vim.notify('Use grr', vim.log.levels.WARN)
  end, opts('LSP references (old)'))
  vim.keymap.set('n', 'grr', function()
    return picker.lsp_references()
  end, opts('LSP references'))
  vim.keymap.set('n', '<leader>lc', vim.lsp.buf.declaration, opts('LSP declaration'))
  vim.keymap.set('n', '<Space>', function()
    return vim.lsp.buf.hover(preview_opts)
  end, { silent = true, buffer = true })
  vim.keymap.set({ 'n', 'x' }, '<leader>lf', function()
    return vim.lsp.buf.format()
  end, opts('LSP format'))
  vim.keymap.set('n', '<leader>li', vim.lsp.buf.incoming_calls, opts('LSP incoming calls'))
  vim.keymap.set('n', '<leader>lh', function()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
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
  vim.keymap.set({ 'n', 'x' }, '<leader>ln', function()
    print(require('nvim-navic').get_location())
  end, opts('Print current location'))

  vim.keymap.set('i', '<C-k>', function()
    vim.lsp.buf.signature_help(preview_opts)
    return ''
  end, { expr = true, buffer = true })
end

function setup.servers()
  local disable_formatting_lsps = { 'lua_ls', 'ts_ls' }

  vim.api.nvim_create_autocmd('LspAttach', {
    group = lsp_group,
    callback = function(ev)
      local client = vim.lsp.get_client_by_id(ev.data.client_id)
      local bufnr = ev.buf

      if not client then
        return
      end

      if client.server_capabilities.documentSymbolProvider then
        require('nvim-navic').attach(client, bufnr)
      end
      setup.attach_to_buffer(client, bufnr)
      if vim.tbl_contains(disable_formatting_lsps, client.name) then
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
      end
    end,
  })

  vim.lsp.config('ts_ls', {
    init_options = {
      preferences = {
        includeInlayParameterNameHints = 'all',
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
  })

  vim.lsp.config('lua_ls', {
    settings = {
      Lua = {
        diagnostics = {
          globals = { 'vim', 'Snacks' },
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
  })

  require('lazydev').setup({
    library = {
      {
        path = '${3rd}/luv/library',
      },
    },
  })

  local null_ls = require('null-ls')
  null_ls.setup({
    sources = {
      -- Code actions
      require('none-ls.code_actions.eslint_d'),

      -- Diagnostics
      require('none-ls.diagnostics.eslint_d'),

      -- Formatters
      require('none-ls.formatting.eslint_d'),
      null_ls.builtins.formatting.stylua,
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

local function refresh_diagnostics(event)
  vim.diagnostic.setloclist({ open = false, namespace = diagnostic_ns })
  show_diagnostics()
  vim.api.nvim__redraw({ buf = event.buf, statusline = true })
  local loclist = vim.fn.getloclist(0, { items = 0, winid = 0 })
  if vim.tbl_isempty(loclist.items) and loclist.winid > 0 then
    vim.api.nvim_win_close(loclist.winid, true)
  end
end

function setup.attach_to_buffer(client, bufnr)
  vim.api.nvim_create_autocmd({ 'CursorHold' }, {
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
          end, 500)
        end
      end,
      group = lsp_group,
    })
  end

  if client:supports_method('textDocument/documentHighlight') then
    vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.document_highlight()
      end,
      group = lsp_group,
    })
    vim.api.nvim_create_autocmd('CursorMoved', {
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.clear_references()
      end,
      group = lsp_group,
    })
  end

  vim.opt.foldmethod = 'expr'
  if vim.treesitter.foldexpr then
    vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    vim.opt.foldtext = ''
  else
    vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
    vim.opt.foldtext = ''
  end
  setup.mappings()
end

return lsp
