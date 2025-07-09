return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  branch = 'main',
  dependencies = {
    { 'nvim-treesitter/nvim-treesitter-textobjects', branch = 'main' },
  },
  lazy = false,
  config = function()
    require('nvim-treesitter').setup()
    require('nvim-treesitter-textobjects').setup()
  end
}
-- treesitter.config = function()
--   require('nvim-treesitter.configs').setup({
--     highlight = {
--       enable = true,
--     },
--     indent = {
--       enable = true,
--     },
--     incremental_selection = {
--       enable = true,
--       keymaps = {
--         init_selection = 'gnn',
--         node_incremental = '.',
--         scope_incremental = 'gnc',
--         node_decremental = ',',
--       },
--     },
--     matchup = {
--       enable = true,
--       disable_virtual_text = true,
--     },
--     textobjects = {
--       enable = true,
--       disable = {},
--       select = {
--         enable = true,
--         keymaps = {
--           ['af'] = '@function.outer',
--           ['if'] = '@function.inner',
--           ['aC'] = '@class.outer',
--           ['iC'] = '@class.inner',
--           ['ac'] = '@conditional.outer',
--           ['ic'] = '@conditional.inner',
--           ['ae'] = '@block.outer',
--           ['ie'] = '@block.inner',
--           ['al'] = '@loop.outer',
--           ['il'] = '@loop.inner',
--           ['is'] = '@statement.inner',
--           ['as'] = '@statement.outer',
--           ['ad'] = '@comment.outer',
--           ['am'] = '@call.outer',
--           ['im'] = '@call.inner',
--         },
--       },
--       swap = {
--         enable = true,
--         swap_next = {
--           ['<leader>a'] = '@parameter.inner',
--         },
--         swap_previous = {
--           ['<leader>A'] = '@parameter.inner',
--         },
--       },
--       move = {
--         enable = true,
--         goto_next_start = {
--           [']m'] = '@function.outer',
--           [']]'] = '@class.outer',
--         },
--         goto_next_end = {
--           [']M'] = '@function.outer',
--           [']['] = '@class.outer',
--         },
--         goto_previous_start = {
--           ['[m'] = '@function.outer',
--           ['[['] = '@class.outer',
--         },
--         goto_previous_end = {
--           ['[M'] = '@function.outer',
--           ['[]'] = '@class.outer',
--         },
--       },
--       lsp_interop = {
--         enable = true,
--         border = 'rounded',
--         peek_definition_code = {
--           ['<leader>dg'] = '@function.outer',
--           ['<leader>dG'] = '@class.outer',
--         },
--       },
--     },
--     ensure_installed = 'all',
--     ignore_install = { 'org' },
--   })
--   return treesitter
-- end
