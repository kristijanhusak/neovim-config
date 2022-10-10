local diagnostic_ns = vim.api.nvim_create_namespace('lsp_diagnostics')
local utils = require('partials.utils')

local setup = {}

local lsp = {
  install = function(packager)
    packager.add('jose-elias-alvarez/null-ls.nvim')
    packager.add('jose-elias-alvarez/typescript.nvim')
    packager.add('SmiteshP/nvim-navic')
    return packager.add('neovim/nvim-lspconfig')
  end,
}
lsp.setup = function()
  local lsp_group = vim.api.nvim_create_augroup('vimrc_lsp', { clear = true })
  vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
      setup.attach_to_buffer(args.buf)
    end,
    group = lsp_group,
  })

  setup.configure()
  setup.mappings()
  setup.servers()

  return lsp
end

function setup.configure()
  vim.diagnostic.config({
    virtual_text = false,
  })

  vim.lsp.handlers['_typescript.rename'] = function(_, result)
    if not result then
      return
    end
    vim.fn.cursor(result.position.line + 1, result.position.character + 2)
    vim.api.nvim_feedkeys(utils.esc('<Esc>'), 'v', true)
    vim.lsp.buf.rename()
    return {}
  end

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
  local telescope = require('telescope.builtin')
  vim.keymap.set('n', '<leader>ld', telescope.lsp_definitions)
  vim.keymap.set('n', '<leader>lw', telescope.lsp_type_definitions)
  vim.keymap.set('n', '<leader>lu', vim.lsp.buf.references)
  vim.keymap.set('n', '<leader>lc', vim.lsp.buf.declaration)
  vim.keymap.set('n', '<leader>lg', telescope.lsp_implementations)
  vim.keymap.set('n', '<Space>', vim.lsp.buf.hover)
  vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format)
  vim.keymap.set('v', '<leader>lf', function()
    return vim.lsp.buf.format()
  end, { silent = true })
  vim.keymap.set('n', '<leader>li', vim.lsp.buf.incoming_calls)
  vim.keymap.set('n', '<leader>lo', vim.lsp.buf.outgoing_calls)
  vim.keymap.set('n', '<leader>lt', vim.lsp.buf.document_symbol)
  vim.keymap.set('n', '<leader>lo', vim.lsp.buf.outgoing_calls)
  vim.keymap.set('n', '<leader>le', function()
    return vim.diagnostic.open_float({ scope = 'line', show_header = false, focusable = false, border = 'rounded' })
  end)
  vim.keymap.set('n', '<Leader>e', vim.diagnostic.setloclist)
  vim.keymap.set('n', '<leader>lr', vim.lsp.buf.rename)
  vim.keymap.set('n', '[g', function()
    return vim.diagnostic.goto_prev({ float = false })
  end)
  vim.keymap.set('n', ']g', function()
    return vim.diagnostic.goto_next({ float = false })
  end)
  vim.keymap.set('n', '<Leader>la', vim.lsp.buf.code_action)
  vim.keymap.set('x', '<Leader>la', function()
    return vim.lsp.buf.code_action()
  end)
end

function setup.servers()
  local nvim_lsp = require('lspconfig')
  local navic = require('nvim-navic')

  local function lsp_setup(opts)
    return vim.tbl_deep_extend('force', {
      flags = {
        debounce_text_changes = 300,
      },
      on_attach = function(client, bufnr)
        navic.attach(client, bufnr)
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
    vim.cmd([[lclose]])
  end
end

function setup.attach_to_buffer(buf)
  vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
    buffer = buf,
    callback = show_diagnostics,
  })
  vim.api.nvim_create_autocmd('DiagnosticChanged', {
    buffer = buf,
    callback = refresh_diagnostics,
  })
  if vim.bo.filetype ~= 'terraform' then
    vim.api.nvim_create_autocmd('CursorHoldI', {
      buffer = buf,
      callback = function()
        vim.defer_fn(vim.lsp.buf.signature_help, 1000)
      end,
    })
  end
  vim.opt.foldmethod = 'expr'
  vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
end

return lsp
