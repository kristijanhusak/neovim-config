local diagnostic_ns = vim.api.nvim_create_namespace('lsp_diagnostics')
local lsp_group = vim.api.nvim_create_augroup('vimrc_lsp', { clear = true })

local lsp = {}
local setup = {}

local preview_opts = {
  border = 'rounded',
  focusable = false,
  silent = true,
}

local progress = vim.defaulttable()
local buf = nil
local win = nil
local open_win = function(width)
  local opts = {
    relative = 'editor',
    row = vim.o.lines - 3,
    col = vim.o.columns - width,
    width = width,
    height = 1,
    style = 'minimal',
    border = 'none',
    focusable = false,
  }
  if win then
    return vim.api.nvim_win_set_config(win, opts)
  end
  buf = vim.api.nvim_create_buf(false, true)
  win = vim.api.nvim_open_win(buf, false, opts)
  vim.api.nvim_set_option_value('winhl', 'Normal:Normal', { win = win })
end
vim.api.nvim_create_autocmd('LspProgress', {
  group = lsp_group,
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
          msg = ('[%d%%%%] %s%s'):format(
            value.kind == 'end' and 100 or value.percentage or 100,
            value.title or '',
            value.message and (' %s'):format(value.message) or ''
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
    local icon = #progress[client.id] == 0 and ' '
      or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]

    local content = table.concat({ icon, msg[#msg] }, ' ')

    open_win(#content)
    if buf then
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, { content })
    end
    if #progress[client.id] == 0 then
      vim.defer_fn(function()
        if win then
          pcall(vim.api.nvim_win_close, win, true)
          win = nil
          buf = nil
        end
      end, 500)
    end
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
      'copilot',
    },
  })

  if vim.g.builtin_autocompletion or vim.g.custom_autocompletion then
    vim.lsp.enable('filepaths_ls')
  end

  if vim.g.builtin_autocompletion then
    vim.lsp.enable('buffer_lsp')
  end

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
          globals = { 'vim', 'Snacks', 'hl' },
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
      {
        path = '/usr/share/hypr/stubs',
      },
      {
        path = '~/.config/hypr',
      },
    },
  })

  local null_ls = require('null-ls')
  null_ls.setup({
    sources = {
      -- Code actions
      require('none-ls.code_actions.eslint_d').with({
        cwd = function()
          return vim.fn.getcwd()
        end,
      }),

      -- Diagnostics
      require('none-ls.diagnostics.eslint_d').with({
        cwd = function()
          return vim.fn.getcwd()
        end,
      }),

      -- Formatters
      require('none-ls.formatting.eslint_d').with({
        cwd = function()
          return vim.fn.getcwd()
        end,
      }),
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

  local ignored_completion_filetypes = { 'markdown', 'text', 'gitcommit', 'org' }

  if vim.lsp.inline_completion and not vim.tbl_contains(ignored_completion_filetypes, vim.bo[bufnr].filetype) then
    vim.lsp.inline_completion.enable(true, {
      bufnr = bufnr,
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

return {
  'neovim/nvim-lspconfig',
  dependencies = {
    'nvimtools/none-ls.nvim',
    'nvimtools/none-ls-extras.nvim',
    'SmiteshP/nvim-navic',
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'folke/lazydev.nvim',
    'antonk52/filepaths_ls.nvim',
  },
  event = 'VeryLazy',
  config = function()
    lsp.config()
  end,
}
