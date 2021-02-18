local lsp = {}
local nvim_lsp = require'lspconfig'
local utils = require'partials/utils'
local lightbulb = require'nvim-lightbulb'

local filetypes = {'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'lua', 'go', 'vim', 'php', 'python'}

vim.cmd [[augroup vimrc_lsp]]
  vim.cmd [[autocmd!]]
  vim.cmd(string.format('autocmd FileType %s call v:lua.kris.lsp.setup()', table.concat(filetypes, ',')))
vim.cmd [[augroup END]]

function lsp.setup()
  vim.cmd[[autocmd CursorHold <buffer> silent! lua require"lspsaga.diagnostic".show_line_diagnostics()]]
  vim.cmd[[autocmd CursorHoldI <buffer> silent! lua kris.lsp.signature_help()]]
  vim.cmd[[autocmd CursorHold,CursorHoldI * lua kris.lsp.show_bulb() ]]
end

function lsp.show_bulb()
  return lightbulb.update_lightbulb({
      sign = { enabled = false },
      float = {
        enabled = true,
        text = '',
        win_opts = {
          offset_x = -(vim.fn.col('.') + 2),
          offset_y = -1,
          winblend = 99
        },
      },
  });
end

function lsp.tag_signature(word)
  local content = {}
  for _, item in ipairs(vim.fn.taglist('^'..word..'$')) do
    if item.kind == 'm' then
      table.insert(content, string.format('%s - %s', item.cmd:match('%([^%)]*%)'), vim.fn.fnamemodify(item.filename, ':t:r')))
    end
  end

  if not vim.tbl_isempty(content) then
    table.insert(content, 1, 'Tag signature')
    require'lspsaga.signaturehelp'.focusable_preview('tag_signature', function()
      return content, vim.lsp.util.try_trim_markdown_code_blocks(content)
    end)
    return true
  end

  return false
end

function lsp.signature_help()
  local is_tag = type(vim.v.completed_item) == 'table' and vim.v.completed_item.menu == '[Tag]'
  if is_tag then
    local show_tag_signature = lsp.tag_signature(vim.v.completed_item.word)
    if show_tag_signature then return end
  end
  return require('lspsaga.signaturehelp').signature_help()
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
  }
})
nvim_lsp.tsserver.setup{}
nvim_lsp.vimls.setup{}
nvim_lsp.intelephense.setup{}
nvim_lsp.gopls.setup{}
nvim_lsp.pyls.setup{}

local lua_lsp_path = '/home/kristijan/github/lua-language-server'
local lua_lsp_bin = lua_lsp_path..'/bin/Linux/lua-language-server'
nvim_lsp.sumneko_lua.setup {
  cmd = {lua_lsp_bin, '-E', lua_lsp_path..'/main.lua'};
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
        -- Setup your lua path
        path = vim.split(package.path, ';'),
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = {'vim'},
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = {
          [vim.fn.expand('$VIMRUNTIME/lua')] = true,
          [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
        },
      },
    },
  },
}

require'lspsaga'.init_lsp_saga({
  rename_prompt_prefix = '',
  error_sign = '',
  warn_sign = '',
  hint_sign = '',
  infor_sign = '',
})

vim.lsp.handlers['_typescript.rename'] = function(_, _, result)
  if not result then return end
  vim.fn.cursor(result.position.line + 1, result.position.character + 1)
  vim.cmd [[:Lspsaga rename]]
  return {}
end

local old_range_params = vim.lsp.util.make_given_range_params
function vim.lsp.util.make_given_range_params(start_pos, end_pos)
  local params = old_range_params(start_pos, end_pos)
  local add = vim.o.selection ~= 'exclusive' and 1 or 0
  params.range['end'].character = params.range['end'].character + add
  return params
end

vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, method, params, client_id, bufnr, config)
  local client = vim.lsp.get_client_by_id(client_id)
  local is_ts = vim.tbl_contains({'typescript', 'typescriptreact'}, vim.bo.filetype)
  if client and client.name == 'tsserver' and not is_ts then return end

  return vim.lsp.diagnostic.on_publish_diagnostics(
    err, method, params, client_id, bufnr, vim.tbl_deep_extend("force", config or {}, { virtual_text = false })
  )
end

utils.keymap('n', '<leader>ld', '<cmd>lua vim.lsp.buf.definition()<CR>', { noremap = false })
utils.keymap('n', '<leader>lc', '<cmd>lua vim.lsp.buf.declaration()<CR>', { noremap = false })
utils.keymap('n', '<leader>lg', '<cmd>lua vim.lsp.buf.implementation()<CR>', { noremap = false })
utils.keymap('n', '<leader>lh', ':Lspsaga hover_doc<CR>', { noremap = false })
utils.keymap('n', '<leader>lH', '<cmd>lua kris.lsp.tag_signature(vim.fn.expand("<cword>"))<CR>')
utils.keymap('n', '<leader>lp', ':Lspsaga preview_definition<CR>', { noremap = false })
utils.keymap('n', '<leader>lf', '<cmd>lua vim.lsp.buf.formatting()<CR>', { noremap = false })
utils.keymap('v', '<leader>lf', ':<C-u>call v:lua.vim.lsp.buf.range_formatting()<CR>', { noremap = false })
utils.keymap('n', '<leader>li', '<cmd>lua vim.lsp.buf.incoming_calls()<CR>', { noremap = false })
utils.keymap('n', '<leader>lo', '<cmd>lua vim.lsp.buf.outgoing_calls()<CR>', { noremap = false })
utils.keymap('n', '<leader>le', '<cmd>lua vim.lsp.util.show_line_diagnostics()<CR>', { noremap = false })
utils.keymap('n', '<Leader>e', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', { noremap = false })
utils.keymap('n', '<leader>lr', ':Lspsaga rename<CR>', { noremap = false })
utils.keymap('n', '[g', ':Lspsaga diagnostic_jump_prev<CR>')
utils.keymap('n', ']g', ':Lspsaga diagnostic_jump_next<CR>')
utils.keymap('n', '<Leader>la', ':Lspsaga code_action<CR>')
utils.keymap('v', '<Leader>la', ':<C-U>Lspsaga range_code_action<CR>')

_G.kris.lsp = lsp
