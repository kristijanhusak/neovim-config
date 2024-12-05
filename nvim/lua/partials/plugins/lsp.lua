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
  setup.lsp_progress()
  setup.mason()
  setup.servers()

  return lsp
end

function setup.lsp_progress()
  ---@type table<number, {token:lsp.ProgressToken, msg:string, done:boolean}[]>
  local progress = vim.defaulttable()
  vim.api.nvim_create_autocmd('LspProgress', {
    ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
    callback = function(ev)
      local client = vim.lsp.get_client_by_id(ev.data.client_id)
      local value = ev.data.params.value --[[@as {percentage?: number, title?: string, message?: string, kind: "begin" | "report" | "end"}]]
      if not client or type(value) ~= 'table' then
        return
      end
      local p = progress[client.id]

      for i = 1, #p + 1 do
        if i == #p + 1 or p[i].token == ev.data.params.token then
          p[i] = {
            token = ev.data.params.token,
            msg = ('[%3d%%] %s%s'):format(
              value.kind == 'end' and 100 or value.percentage or 100,
              value.title or '',
              value.message and (' **%s**'):format(value.message) or ''
            ),
            done = value.kind == 'end',
          }
          break
        end
      end

      local msg = {} ---@type string[]
      progress[client.id] = vim.tbl_filter(function(v)
        return table.insert(msg, v.msg) or not v.done
      end, p)

      local spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }
      vim.notify(table.concat(msg, '\n'), vim.log.levels.INFO, {
        id = 'lsp_progress',
        title = client.name,
        opts = function(notif)
          notif.icon = #progress[client.id] == 0 and ' '
            or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
        end,
      })
    end,
  })
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
    },
  })

  vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, preview_opts)

  vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, preview_opts)

  ---@param desc string
  ---@return table
  local opts = function(desc)
    return { buffer = true, silent = true, desc = desc }
  end

  vim.keymap.set('n', '<leader>lg', function()
    return require('telescope.builtin').lsp_implementations()
  end, opts('LSP implementations'))
  vim.keymap.set('n', '<C-]>', function()
    return require('telescope.builtin').lsp_definitions()
  end, opts('LSP implementations'))
  vim.keymap.set('n', 'gD', function()
    return require('telescope.builtin').lsp_definitions()
  end, opts('LSP definitions'))
  vim.keymap.set('n', '<leader>ld', function()
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
  vim.keymap.set('n', '<Leader>e', vim.diagnostic.setloclist, opts('LSP diagnostics list'))
  vim.keymap.set('n', '<leader>lr', vim.lsp.buf.rename, opts('LSP rename'))
  vim.keymap.set('n', '<Leader>la', vim.lsp.buf.code_action, opts('LSP code action'))
  vim.keymap.set('x', '<Leader>la', function()
    return vim.lsp.buf.code_action()
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
  local ok, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
  if ok then
    capabilities = vim.tbl_deep_extend('force', capabilities, cmp_nvim_lsp.default_capabilities(), {
      workspace = {
        didChangeWatchedFiles = { dynamicRegistration = false },
      },
    })
  else
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
  end

  local function lsp_setup(opts)
    opts = opts or {}
    return vim.tbl_deep_extend('force', {
      capabilities = capabilities,
      on_attach = function(client, bufnr)
        if
          require('partials.utils').enable_builtin_lsp_completion()
          and client.supports_method('textDocument/completion')
        then
          local icons = require('partials.utils').lsp_kind_icons()
          vim.lsp.completion.enable(true, client.id, bufnr, {
            autotrigger = true,
            convert = function(item)
              local kind = vim.lsp.protocol.CompletionItemKind[item.kind] or 'Text'
              return {
                kind = icons[kind],
                kind_hlgroup = ('CmpItemKind%s'):format(kind),
                menu = kind,
              }
            end,
            fallback = function()
              require('partials.utils').feedkeys('<C-n>', 'n')
            end,
          })
        end
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
          return _G.kris.diagnostic_icons[diagnostic.severity]
        end or '',
      },
      severity_sort = true,
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
