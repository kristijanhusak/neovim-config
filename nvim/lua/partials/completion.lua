local utils = require'partials/utils'
vim.o.pumheight = 15
vim.cmd('set completeopt-=preview')

require'compe'.setup({
  enabled = true,
  debug = false,
  min_length = 1,
  auto_preselect = false,
  source = {
    path = true,
    buffer = true,
    tags = true,
    vsnip = true,
    nvim_lsp = true,
    nvim_lua = false
  }
})

-- local function check_back_space()
--   local col = vim.fn.col('.') - 1
--   return col <= 0 or vim.fn.getline('.')[col - 1]:match('%s')
-- end

-- local function tab_completion()
--   if vim.fn['vsnip#jumpable'](1) then
--     return '<Plug>(vsnip-jump-next)'
--   end

--   if vim.fn.pumvisible() then
--     return '<C-n>'
--   end

--   if check_back_space() then
--     return '<TAB>'
--   end

--   if vim.fn['vsnip#expandable']() then
--     return '<Plug>(vsnip-expand)'
--   end

--   return vim.fn['compe#complete']()
-- end

-- utils.keymap('i', '<TAB>', utils.esc(':<C-u>lua require"partials/completion".tab_completion()<CR>'), {
--   expr = true,
--   noremap = false
-- })

-- utils.keymap('i', '<S-TAB>', 'pumvisible() ? "<C-p>" : vsnip#jumpable(-1) ? "<Plug>(vsnip-jump-prev)" : "<S-TAB>"', {
--   expr = true,
--   noremap = false
-- })

-- utils.keymap('s', '<TAB>', 'vsnip#available(1)  ? "<Plug>(vsnip-expand-or-jump)" : "<TAB>"', {
--   expr = true,
--   noremap = false
-- })

-- utils.keymap('s', '<S-TAB>', 'vsnip#available(-1)  ? "<Plug>(vsnip-jump-prev)" : "<S-TAB>"', {
--   expr = true,
--   noremap = false
-- })

-- utils.keymap('i', '<CR>', 'pumvisible() && complete_info()["selected"] != "-1" ? compe#confirm("<CR>") : vsnip#expandable() ? "<Plug>(vsnip-expand)" : "<Plug>(PearTreeExpand)"', {
--   expr = true,
--   noremap = false
-- })

utils.keymap('n', '<leader>ld', '<cmd>lua vim.lsp.buf.definition()<CR>',{ noremap = false })
utils.keymap('n', '<leader>lc', '<cmd>lua vim.lsp.buf.declaration()<CR>',{ noremap = false })
utils.keymap('n', '<leader>lg', '<cmd>lua vim.lsp.buf.implementation()<CR>',{ noremap = false })
utils.keymap('n', '<leader>lu', '<cmd>lua vim.lsp.buf.references()<CR>',{ noremap = false })
utils.keymap('n', '<leader>lr', '<cmd>lua vim.lsp.buf.rename()<CR>',{ noremap = false })
utils.keymap('n', '<leader>lh', '<cmd>lua vim.lsp.buf.hover()<CR>',{ noremap = false })
utils.keymap('n', '<leader>ls', '<cmd>lua vim.lsp.buf.signature_help()<CR>',{ noremap = false })
utils.keymap('n', '<leader>lf', '<cmd>lua vim.lsp.buf.formatting()<CR>',{ noremap = false })
utils.keymap('n', '<leader>lf', ':<C-u>call v:lua.vim.lsp.buf.range_formatting()<CR>',{ noremap = false })
utils.keymap('n', '<leader>la', ':call v:lua.vim.lsp.buf.code_action()<CR>',{ noremap = false })
utils.keymap('n', '<leader>la', ':<C-u>call v:lua.vim.lsp.buf.range_code_action()<CR>',{ noremap = false })
utils.keymap('n', '<leader>li', '<cmd>lua vim.lsp.buf.incoming_calls()<CR>',{ noremap = false })
utils.keymap('n', '<leader>lo', '<cmd>lua vim.lsp.buf.outgoing_calls()<CR>',{ noremap = false })
utils.keymap('n', '<leader>le', '<cmd>lua vim.lsp.util.show_line_diagnostics()<CR>',{ noremap = false })
utils.keymap('n', '<leader>lt', '<cmd>lua vim.lsp.buf.document_symbol()<CR>',{ noremap = false })
utils.keymap('n', '<leader>lT', '<cmd>lua vim.lsp.buf.workspace_symbol()<CR>',{ noremap = false })

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
