local abbreviations = {
  Wq = 'wq',
  WQ = 'wq',
  Wqa = 'wqa',
  W = 'w',
  Q = 'q',
  Qa = 'qa',
  Bd = 'bd',
  wrap = 'set wrap',
  nowrap = 'set nowrap',
  E = 'e',
  Gco = 'Git checkout',
  Gcb = 'Git checkout -b',
  Gblame = 'Git blame',
}

for left, right in pairs(abbreviations) do
  vim.cmd(string.format('cnoreabbrev %s %s', left, right))
end
