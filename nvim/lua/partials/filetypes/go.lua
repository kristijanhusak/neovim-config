vim.cmd [[augroup vimrc_go]]
  vim.cmd [[autocmd!]]
  vim.cmd [[autocmd FileType go setlocal noexpandtab tabstop=4]]
  vim.cmd [[autocmd FileType go nnoremap <Leader>xt :GoTest<CR>]]
  vim.cmd [[autocmd FileType go nnoremap <Leader>xx :GoTestFunc<CR>]]
vim.cmd [[augroup END]]

vim.g.go_fmt_command = 'goimports'
vim.g.go_echo_go_info = 0
vim.g.go_highlight_extra_types = 1
vim.g.go_highlight_functions = 1
vim.g.go_highlight_function_parameters = 1
vim.g.go_highlight_function_calls = 1
vim.g.go_highlight_types = 1
vim.g.go_highlight_fields = 1
vim.g.go_highlight_variable_declarations = 1
vim.g.go_highlight_variable_assignments = 1
vim.g.go_highlight_operators = 1
vim.g.go_highlight_build_constraints = 1
vim.g.go_highlight_generate_tags = 1
vim.g.go_highlight_format_strings = 1
vim.g.go_highlight_diagnostic_errors = 1
vim.g.go_highlight_diagnostic_warnings = 1
