local abbreviations = {
  Wq = 'wq',
  WQ = 'wq',
  Wqa = 'wqa',
  W = 'w',
  Q = 'q',
  Qa = 'qa',
  Bd = 'bd',
  E = 'e',
  Gco = 'Git checkout',
  Gcb = 'Git checkout -b',
  Gblame = 'Git blame',
}

for left, right in pairs(abbreviations) do
  vim.cmd.cnoreabbrev(('%s %s'):format(left, right))
end
