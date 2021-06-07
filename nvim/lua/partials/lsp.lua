local lsp = {
  last_actions = {},
}
local nvim_lsp = require'lspconfig'
local utils = require'partials/utils'
local last_completed_item = { menu = nil, word = nil }
local ts_utils = require'nvim-treesitter/ts_utils'

local filetypes = {'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'lua', 'go', 'vim', 'php', 'python'}

vim.cmd [[augroup vimrc_lsp]]
  vim.cmd [[autocmd!]]
  vim.cmd(string.format('autocmd FileType %s call v:lua.kris.lsp.setup()', table.concat(filetypes, ',')))
vim.cmd [[augroup END]]

function lsp.setup()
  vim.cmd[[autocmd CursorMoved <buffer> lua kris.utils.debounce('CursorHold', kris.lsp.on_cursor_hold) ]]
  vim.cmd[[autocmd CursorMovedI,InsertEnter <buffer> lua kris.utils.debounce('CursorHoldI', kris.lsp.signature_help) ]]
  vim.cmd[[autocmd CompleteDone <buffer> lua kris.lsp.save_completed_item()]]
  vim.cmd[[
    sign define LspDiagnosticsSignError text= texthl=LspDiagnosticsSignError linehl= numhl=
    sign define LspDiagnosticsSignWarning text= texthl=LspDiagnosticsSignWarning linehl= numhl=
    sign define LspDiagnosticsSignInformation text= texthl=LspDiagnosticsSignInformation linehl= numhl=
    sign define LspDiagnosticsSignHint text= texthl=LspDiagnosticsSignHint linehl= numhl=
  ]]
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
nvim_lsp.pyls.setup{}
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

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
  vim.lsp.handlers.signature_help, { border = "single", focusable = false }
)

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
  vim.lsp.handlers.hover, { border = "single", focusable = false }
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
    border = 'single',
  })
  vim.api.nvim_set_current_win(winnr)
  utils.buf_keymap(bufnr, 'n', '<CR>', '<cmd>lua kris.lsp.select_code_action()<CR>')
end

function lsp.save_completed_item()
  if type(vim.v.completed_item) ~= 'table' or not vim.v.completed_item.word then return end
  last_completed_item = vim.v.completed_item
end

-- Use custom implementation of CursorHold and CursorHoldI
-- until https://github.com/neovim/neovim/issues/12587 is resolved
function lsp.on_cursor_hold()
  if vim.fn.mode() ~= 'i' then
    vim.lsp.diagnostic.show_line_diagnostics({ border = 'single', show_header = false, focusable = false })
  end
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
      border = 'single',
      focusable = false,
    })
    return true
  end

  return false
end

function lsp.signature_help()
  if last_completed_item.menu == '[Tag]' and vim.fn.pumvisible() == 0 then
    local node = ts_utils.get_node_at_cursor()
    local current_node = ts_utils.get_node_text(node)[1]
    local last_node = ts_utils.get_node_text(ts_utils.get_previous_node(node))[1]
    local last_method = vim.fn.split(last_node, '\\.')
    last_method = last_method[#last_method]
    local show_tag_signature = false
    if current_node:match('%(.*%)') and last_method == last_completed_item.word then
      show_tag_signature = lsp.tag_signature(last_completed_item.word)
    end
    if show_tag_signature then return end
  end
  return vim.lsp.buf.signature_help()
end

function lsp.rename()
  local current_val = vim.fn.expand('<cword>')
  local bufnr, winnr = vim.lsp.util.open_floating_preview({ current_val }, '', {
    border = 'single',
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


utils.keymap('n', '<leader>ld', '<cmd>lua vim.lsp.buf.definition()<CR>', { noremap = false })
utils.keymap('n', '<leader>lc', '<cmd>lua vim.lsp.buf.declaration()<CR>', { noremap = false })
utils.keymap('n', '<leader>lg', '<cmd>lua vim.lsp.buf.implementation()<CR>', { noremap = false })
utils.keymap('n', '<leader>lh', '<cmd>lua vim.lsp.buf.hover()<CR>', { noremap = false })
utils.keymap('n', '<leader>lH', '<cmd>lua kris.lsp.tag_signature(vim.fn.expand("<cword>"))<CR>')
utils.keymap('n', '<leader>lf', '<cmd>lua vim.lsp.buf.formatting()<CR>', { noremap = false })
utils.keymap('v', '<leader>lf', ':<C-u>call v:lua.vim.lsp.buf.range_formatting()<CR>', { noremap = false })
utils.keymap('n', '<leader>li', '<cmd>lua vim.lsp.buf.incoming_calls()<CR>', { noremap = false })
utils.keymap('n', '<leader>lo', '<cmd>lua vim.lsp.buf.outgoing_calls()<CR>', { noremap = false })
utils.keymap('n', '<leader>le', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', { noremap = false })
utils.keymap('n', '<Leader>e', ':LspTroubleToggle lsp_document_diagnostics<CR>')
utils.keymap('n', '<leader>lr', '<cmd>lua kris.lsp.rename()<CR>', { noremap = false })
utils.keymap('n', '[g', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>')
utils.keymap('n', ']g', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>')
utils.keymap('n', '<Leader>la', '<cmd>lua vim.lsp.buf.code_action()<CR>')
utils.keymap('v', '<Leader>la', ':<C-u>lua vim.lsp.buf.range_code_action()<CR>')

_G.kris.lsp = lsp
