return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  dependencies = {
    { 'nvim-treesitter/nvim-treesitter-textobjects' },
  },
  config = function()
    require('nvim-treesitter').setup()
    require('nvim-treesitter-textobjects').setup()
    local valid_parsers = vim.tbl_filter(function(parser)
      return not vim.tbl_contains({ 'robots', 'jsonc', 'fusion', 'blueprint' }, parser)
    end, require('nvim-treesitter').get_available(2))
    require('nvim-treesitter').install(valid_parsers)
    vim.api.nvim_create_autocmd('FileType', {
      pattern = '*',
      group = vim.api.nvim_create_augroup('nvim-treesitter-fts', { clear = true }),
      callback = function(args)
        local parser = vim.treesitter.get_parser(args.buf)
        if parser then
          vim.treesitter.start(args.buf)
        end
      end,
    })

    vim.api.nvim_create_user_command('TSUpdate', function()
      require('nvim-treesitter.install').update(valid_parsers, { summary = true })
    end, {
      nargs = '*',
      bar = true,
      desc = 'Update installed treesitter parsers',
    })

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
  end,
}
