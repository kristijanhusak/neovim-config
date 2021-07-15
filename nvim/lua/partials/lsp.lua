local lsp = {
  last_actions = {},
}
local nvim_lsp = require'lspconfig'
local utils = require'partials/utils'
local diagnostic_ns = vim.api.nvim_create_namespace('lsp_diagnostic')

local filetypes = {'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'lua', 'go', 'vim', 'php', 'python'}

vim.cmd [[augroup vimrc_lsp]]
  vim.cmd [[autocmd!]]
  vim.cmd(string.format('autocmd FileType %s call v:lua.kris.lsp.setup()', table.concat(filetypes, ',')))
  vim.cmd[[autocmd User LspDiagnosticsChanged :lua kris.lsp.refresh_diagnostics()]]
vim.cmd [[augroup END]]

function lsp.setup()
  vim.cmd[[autocmd CursorHold,CursorHoldI <buffer> lua kris.lsp.show_diagnostics()]]
  require'lsp_signature'.on_attach()
end

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
  },
})
nvim_lsp.tsserver.setup{}
nvim_lsp.vimls.setup{}
nvim_lsp.intelephense.setup{}
nvim_lsp.gopls.setup{}
nvim_lsp.pylsp.setup{}
local lua_lsp_path = '/home/kristijan/github/lua-language-server'
local lua_lsp_bin = lua_lsp_path..'/bin/Linux/lua-language-server'
nvim_lsp.sumneko_lua.setup(require("lua-dev").setup({
  lspconfig = {
    cmd = {lua_lsp_bin, '-E', lua_lsp_path..'/main.lua'},
    settings = {
      Lua = {
        diagnostics = {
          globals = {'vim', 'describe', 'it', 'before_each', 'after_each'},
        },
      },
    }
  }
}))

vim.lsp.handlers['_typescript.rename'] = function(_, _, result)
  if not result then return end
  vim.fn.cursor(result.position.line + 1, result.position.character + 1)
  vim.api.nvim_feedkeys(utils.esc('<Esc>'), 'v', true)
  lsp.rename()
  return {}
end

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
  vim.lsp.handlers.hover, { border = "rounded", focusable = false }
)

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, { virtual_text = false }
)

vim.lsp.handlers['textDocument/codeAction'] = function(_, _, actions)
  if actions == nil or vim.tbl_isempty(actions) then
    print("No code actions available")
    return
  end

  local option_strings = {}
  for i, action in ipairs(actions) do
    local title = action.title:gsub('\r\n', '\\r\\n')
    title = title:gsub('\n', '\\n')
    table.insert(option_strings, string.format("%d. %s", i, title))
  end

  kris.lsp.last_actions = actions

  local bufnr, winnr = vim.lsp.util.open_floating_preview(option_strings, '', {
    border = 'rounded',
  })
  vim.api.nvim_set_current_win(winnr)
  utils.buf_keymap(bufnr, 'n', '<CR>', '<cmd>lua kris.lsp.select_code_action()<CR>')
end

local custom_symbol_callback = function(_, _, result, _, bufnr)
  if not result or vim.tbl_isempty(result) then return end

  local items = vim.lsp.util.symbols_to_items(result, bufnr)
  local items_by_name = {}
  for _, item in ipairs(items) do
    items_by_name[item.text] = item
  end

  local opts = vim.fn['fzf#wrap']({
      source = vim.tbl_keys(items_by_name),
      sink = function() end,
      options = {'--prompt', 'Symbol > '},
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
  local line = vim.api.nvim_win_get_cursor(0)[1] - 1
  local diagnostics = vim.lsp.diagnostic.get_line_diagnostics()
  if #diagnostics == 0 then
    return vim.api.nvim_buf_clear_namespace(0, diagnostic_ns, 0, -1)
  end
  local virt_texts = vim.lsp.diagnostic.get_virtual_text_chunks_for_line(0, line, diagnostics)
  vim.api.nvim_buf_set_virtual_text(0, diagnostic_ns, line, virt_texts, {})
end

function lsp.tag_signature(word)
  local content = {}
  for _, item in ipairs(vim.fn.taglist('^'..word..'$')) do
    if item.kind == 'm' then
      table.insert(content, string.format('%s - %s', item.cmd:match('%([^%)]*%)'), vim.fn.fnamemodify(item.filename, ':t:r')))
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

function lsp.rename()
  local current_val = vim.fn.expand('<cword>')
  local bufnr, winnr = vim.lsp.util.open_floating_preview({ current_val }, '', {
    border = 'rounded',
    width = math.max(current_val:len() + 10, 30),
  })
  vim.api.nvim_set_current_win(winnr)
  vim.api.nvim_buf_set_option(bufnr, 'modifiable', true)
  vim.api.nvim_win_set_option(winnr, 'sidescrolloff', 0)
  utils.buf_keymap(bufnr, 'i', '<CR>', '<cmd>lua kris.lsp.do_rename()<CR>')
  vim.defer_fn(function()
    vim.cmd[[startinsert!]]
  end, 10)
end

function lsp.do_rename()
  local new_name = vim.trim(vim.fn.getline('.'))
  vim.api.nvim_win_close(0, true)
  vim.api.nvim_feedkeys(utils.esc('<Esc>'), 'i', true)
  vim.lsp.buf.rename(new_name)
end

function lsp.select_code_action()
  local action_chosen = lsp.last_actions[vim.fn.line('.')]
  vim.api.nvim_win_close(0, true)
  if action_chosen.edit or type(action_chosen.command) == "table" then
    if action_chosen.edit then
      vim.lsp.util.apply_workspace_edit(action_chosen.edit)
    end
    if type(action_chosen.command) == "table" then
      vim.lsp.buf.execute_command(action_chosen.command)
    end
  else
    vim.lsp.buf.execute_command(action_chosen)
  end
end

function lsp.refresh_diagnostics()
  vim.lsp.diagnostic.set_loclist({open_loclist = false})
  lsp.show_diagnostics()
  if vim.tbl_isempty(vim.fn.getloclist(0)) then
    vim.cmd[[lclose]]
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
utils.keymap('n', '<leader>le', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics({ border = "rounded", show_header = false, focusable = false })<CR>')
utils.keymap('n', '<Leader>e', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>')
utils.keymap('n', '<Leader>E', '<cmd>lua vim.lsp.diagnostic.set_loclist({ workspace = true })<CR>')
utils.keymap('n', '<leader>lr', '<cmd>lua kris.lsp.rename()<CR>')
utils.keymap('n', '[g', '<cmd>lua vim.lsp.diagnostic.goto_prev({ enable_popup = false })<CR>')
utils.keymap('n', ']g', '<cmd>lua vim.lsp.diagnostic.goto_next({ enable_popup = false })<CR>')
utils.keymap('n', '<Leader>la', '<cmd>lua vim.lsp.buf.code_action()<CR>')
utils.keymap('v', '<Leader>la', ':<C-u>lua vim.lsp.buf.range_code_action()<CR>')

vim.cmd[[
sign define LspDiagnosticsSignError text= texthl=LspDiagnosticsSignError linehl= numhl=
sign define LspDiagnosticsSignWarning text= texthl=LspDiagnosticsSignWarning linehl= numhl=
sign define LspDiagnosticsSignInformation text= texthl=LspDiagnosticsSignInformation linehl= numhl=
sign define LspDiagnosticsSignHint text= texthl=LspDiagnosticsSignHint linehl= numhl=
]]

_G.kris.lsp = lsp
