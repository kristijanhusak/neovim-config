return {
  'kristijanhusak/vim-dadbod-ui',
  dependencies = {
    { 'tpope/vim-dadbod', lazy = true },
    { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' }, lazy = true },
  },
  event = 'VeryLazy',
  cmd = {
    'DBUI',
    'DBUIToggle',
    'DBUIAddConnection',
    'DBUIFindBuffer',
  },
  init = function()
    vim.g.db_ui_show_help = 0
    vim.g.db_ui_win_position = 'right'
    vim.g.db_ui_use_nerd_fonts = 1
    vim.g.db_ui_use_nvim_notify = 1

    vim.g.db_ui_save_location = '~/Dropbox/dbui'
    vim.g.db_ui_tmp_query_location = '~/code/queries'

    vim.g.db_ui_hide_schemas = { 'pg_toast_temp.*' }
  end,
}
