local local_vimrc = vim.fn.getcwd() .. '/.nvimrc'
if vim.loop.fs_stat(local_vimrc) then
  local source = true
  if vim.secure then
    source = vim.secure.read(local_vimrc)
  end
  if source then
    vim.cmd.source(local_vimrc)
  end
end
