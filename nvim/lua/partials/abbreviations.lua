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
  GcLog = [[tabnew \| Gclog]],
  Gclog = [[tabnew \| Gclog]],
  ['0Gclog'] = [[tabe % \| 0Gclog]],
  ['0GcLog'] = [[tabe % \| 0Gclog]],
}

for left, right in pairs(abbreviations) do
  vim.cmd.cnoreabbrev(('%s %s'):format(left, right))
end
