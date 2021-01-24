_G.kris.completion = {}
local utils = require'partials/utils'
local npairs = require'nvim-autopairs'
vim.o.pumheight = 15
vim.cmd('set completeopt-=preview')

require'compe'.setup({
  enabled = true,
  debug = false,
  min_length = 1,
  preselect = 'disable',
  source = {
    path = true,
    buffer = { ignored_filetypes = {'sql'} },
    tags = { ignored_filetypes = {'sql'} },
    vsnip = true,
    nvim_lsp = true,
    vim_dadbod_completion = true,
    nvim_lua = false
  }
})

local function check_back_space()
  local col = vim.fn.col('.') - 1
  return col <= 0 or vim.fn.getline('.'):sub(col, col):match('%s')
end

function _G.kris.completion.tab_completion()
  if vim.fn['vsnip#jumpable'](1) > 0 then
    return utils.esc('<Plug>(vsnip-jump-next)')
  end

  if vim.fn.pumvisible() > 0 then
    return utils.esc('<C-n>')
  end

  if check_back_space() then
    return utils.esc('<TAB>')
  end

  if vim.fn['vsnip#expandable']() > 0 then
    return utils.esc('<Plug>(vsnip-expand)')
  end

  return vim.fn['compe#complete']()
end

utils.keymap('i', '<TAB>', 'v:lua.kris.completion.tab_completion()', { expr = true, noremap = false })

utils.keymap('i', '<S-TAB>', 'pumvisible() ? "<C-p>" : vsnip#jumpable(-1) ? "<Plug>(vsnip-jump-prev)" : "<S-TAB>"', {
  expr = true,
  noremap = false
})

utils.keymap('s', '<TAB>', 'vsnip#available(1)  ? "<Plug>(vsnip-expand-or-jump)" : "<TAB>"', {
  expr = true,
  noremap = false
})

utils.keymap('s', '<S-TAB>', 'vsnip#available(-1)  ? "<Plug>(vsnip-jump-prev)" : "<S-TAB>"', {
  expr = true,
  noremap = false
})

function _G.kris.completion.handle_cr()
  if vim.fn.pumvisible() ~= 0 and vim.fn.complete_info()['selected'] ~= -1 then
    return vim.fn['compe#confirm']('<CR>')
  end

  if vim.fn['vsnip#expandable']() ~= 0 then
    return npairs.esc('<Plug>(vsnip-expand)')
  end

  return npairs.check_break_line_char()
end

utils.keymap('i', '<CR>', 'v:lua.kris.completion.handle_cr()', {
  expr = true,
  noremap = false
})

utils.keymap('n', '<leader>ld', '<cmd>lua vim.lsp.buf.definition()<CR>', { noremap = false })
utils.keymap('n', '<leader>lc', '<cmd>lua vim.lsp.buf.declaration()<CR>', { noremap = false })
utils.keymap('n', '<leader>lg', '<cmd>lua vim.lsp.buf.implementation()<CR>', { noremap = false })
utils.keymap('n', '<leader>lr', '<cmd>lua vim.lsp.buf.rename()<CR>', { noremap = false })
utils.keymap('n', '<leader>lh', '<cmd>lua vim.lsp.buf.hover()<CR>', { noremap = false })
utils.keymap('n', '<leader>ls', '<cmd>lua vim.lsp.buf.signature_help()<CR>', { noremap = false })
utils.keymap('n', '<leader>lf', '<cmd>lua vim.lsp.buf.formatting()<CR>', { noremap = false })
utils.keymap('v', '<leader>lf', ':<C-u>call v:lua.vim.lsp.buf.range_formatting()<CR>', { noremap = false })
utils.keymap('n', '<leader>li', '<cmd>lua vim.lsp.buf.incoming_calls()<CR>', { noremap = false })
utils.keymap('n', '<leader>lo', '<cmd>lua vim.lsp.buf.outgoing_calls()<CR>', { noremap = false })
utils.keymap('n', '<leader>le', '<cmd>lua vim.lsp.util.show_line_diagnostics()<CR>', { noremap = false })
utils.keymap('n', '[g', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', { noremap = false })
utils.keymap('n', ']g', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', { noremap = false })
utils.keymap('n', '<Leader>e', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', { noremap = false })
utils.keymap('n', '[e', ':lprevious<CR>')
utils.keymap('n', ']e', ':lnext<CR>')

local ignores = {
  '*.o',
  '*.obj,*~',
  '*.git*',
  '*.meteor*',
  '*vim/backups*',
  '*sass-cache*',
  '*mypy_cache*',
  '*__pycache__*',
  '*cache*',
  '*logs*',
  '*node_modules*',
  '**/node_modules/**',
  '*DS_Store*',
  '*.gem',
  'log/**',
  'tmp/**',
}

vim.o.wildignore = table.concat(ignores, ',')
