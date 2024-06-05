return {
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
  config = function()
    local enable_builtin_lsp_completion = require('partials.utils').enable_builtin_lsp_completion()
    local npairs = require('nvim-autopairs')
    npairs.setup()

    npairs.setup({
      map_cr = not enable_builtin_lsp_completion,
    })

    if enable_builtin_lsp_completion then
      _G.kris.cr = function()
        if vim.fn.pumvisible() == 0 then
          return npairs.autopairs_cr()
        end

        if vim.fn.complete_info({ 'selected' }).selected ~= -1 then
          return npairs.esc('<c-y>')
        end
        return npairs.esc('<c-e>') .. npairs.autopairs_cr()
      end
      vim.api.nvim_set_keymap('i', '<cr>', 'v:lua.kris.cr()', { expr = true, noremap = true })
    end
  end,
}
