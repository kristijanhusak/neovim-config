local pqf = {
  url = 'git@gitlab.com:yorickpeterse/nvim-pqf.git',
  event = 'VeryLazy'
}
pqf.config = function()
  require('pqf').setup()
end

return pqf
