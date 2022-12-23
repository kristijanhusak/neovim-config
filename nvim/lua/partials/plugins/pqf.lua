local pqf = {
  url = 'https://gitlab.com/yorickpeterse/nvim-pqf',
  event = 'VeryLazy',
}
pqf.config = function()
  require('pqf').setup()
end

return pqf
