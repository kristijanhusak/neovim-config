local local_vimrc = vim.fn.getcwd() .. '/.nvimrc'
if vim.loop.fs_stat(local_vimrc) then
  if vim.secure then
    vim.secure.read(local_vimrc)
  else
    vim.cmd.source(local_vimrc)
  end
end
