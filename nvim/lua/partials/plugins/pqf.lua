local pqf = {
  url = 'git@gitlab.com:yorickpeterse/nvim-pqf.git',
  ft = 'qf',
}
pqf.config = function()
  require('pqf').setup()
end

return pqf
