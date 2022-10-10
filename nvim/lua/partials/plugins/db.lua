local db = {
  install = function(packager)
    packager.add('tpope/vim-dadbod')
    packager.add('kristijanhusak/vim-dadbod-completion', { type = 'opt' })
    return packager.add('kristijanhusak/vim-dadbod-ui')
  end,
}
db.setup = function()
  vim.g.db_ui_show_help = 0
  vim.g.db_ui_win_position = 'right'
  vim.g.db_ui_use_nerd_fonts = 1

  vim.g.db_ui_save_location = '~/Dropbox/dbui'
  vim.g.db_ui_tmp_query_location = '~/code/queries'

  vim.g.db_ui_hide_schemas = { 'pg_toast_temp.*' }

  local db_augroup = vim.api.nvim_create_augroup('plugin_db', { clear = true })

  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'sql',
    command = 'packadd vim-dadbod-completion | runtime after/plugin/vim_dadbod_completion.lua',
    group = db_augroup,
  })

  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'sql',
    command = [[setlocal omnifunc=vim_dadbod_completion#omni formatprg=sql-formatter\ -l\ postgresql]],
    group = db_augroup,
  })

  return db
end

return db
