return {
  'arborist-ts/arborist.nvim',
  dependencies = {
    { 'nvim-treesitter/nvim-treesitter-textobjects' },
  },
  config = function()
    require('arborist').setup({
      ignore = {'orgagenda', 'org', 'snacks_input'},
      disable = {
        indent = {'tsx'}
      }
    })
    require('nvim-treesitter-textobjects').setup()

    -- Select
    vim.keymap.set({ 'x', 'o' }, 'af', function()
      require('nvim-treesitter-textobjects.select').select_textobject('@function.outer', 'textobjects')
    end)
    vim.keymap.set({ 'x', 'o' }, 'if', function()
      require('nvim-treesitter-textobjects.select').select_textobject('@function.inner', 'textobjects')
    end)

    -- Swap
    vim.keymap.set('n', '<leader>ak', function()
      require('nvim-treesitter-textobjects.swap').swap_next('@parameter.inner')
    end)
    vim.keymap.set('n', '<leader>aK', function()
      require('nvim-treesitter-textobjects.swap').swap_previous('@parameter.inner')
    end)
  end
}
