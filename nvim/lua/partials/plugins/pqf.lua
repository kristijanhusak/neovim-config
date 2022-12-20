local pqf = {
  'https://gitlab.com/yorickpeterse/nvim-pqf',
  ft = 'qf',
}
pqf.config = function()
  require('pqf').setup()
  return pqf
end

return pqf
