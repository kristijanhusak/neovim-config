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
    require('nvim-treesitter').install(require('nvim-treesitter').get_available(2))
    vim.api.nvim_create_autocmd('FileType', {
      pattern = {
        'c',
        'cpp',
        'diff',
        'dockerfile',
        'gitdiff',
        'gitignore',
        'go',
        'graphql',
        'javascript',
        'javascriptreact',
        'lua',
        'markdown',
        'mysql',
        'pgsql',
        'php',
        'python',
        'ruby',
        'sh',
        'sql',
        'terraform',
        'toml',
        'typescript',
        'typescriptreact',
        'vim',
        'yaml',
      },
      group = vim.api.nvim_create_augroup('nvim-treesitter-fts', { clear = true }),
      callback = function(args)
        vim.treesitter.start(args.buf)
      end,
    })

    -- Select
    vim.keymap.set({ 'x', 'o' }, 'af', function()
      require('nvim-treesitter-textobjects.select').select_textobject('@function.outer', 'textobjects')
    end)
    vim.keymap.set({ 'x', 'o' }, 'if', function()
      require('nvim-treesitter-textobjects.select').select_textobject('@function.inner', 'textobjects')
    end)

    -- Swap
    vim.keymap.set('n', '<leader>a', function()
      require('nvim-treesitter-textobjects.swap').swap_next('@parameter.inner')
    end)
    vim.keymap.set('n', '<leader>A', function()
      require('nvim-treesitter-textobjects.swap').swap_previous('@parameter.inner')
    end)
  end,
}
