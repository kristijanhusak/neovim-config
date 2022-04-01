local mappings = {}
-- Comment map
vim.keymap.set('n', '<Leader>c', 'gcc', { remap = true })
-- Line comment command
vim.keymap.set('v', '<Leader>c', 'gc', { remap = true })

-- Map save to Ctrl + S
vim.keymap.set('', '<c-s>', ':w<CR>', { remap = true })
vim.keymap.set('i', '<c-s>', '<C-o>:w<CR>', { remap = true })
vim.keymap.set('n', '<Leader>s', ':w<CR>')

-- Open vertical split
vim.keymap.set('n', '<Leader>v', '<C-w>v')

-- Move between slits
vim.keymap.set('n', '<c-h>', '<C-w>h')
vim.keymap.set('n', '<c-j>', '<C-w>j')
vim.keymap.set('n', '<c-k>', '<C-w>k')
vim.keymap.set('n', '<c-l>', '<C-w>l')
vim.keymap.set('n', '<c-h>', '<C-\\><C-n><C-w>h')
vim.keymap.set('n', '<c-l>', '<C-\\><C-n><C-w>l')

-- Down is really the next line
vim.keymap.set('n', 'j', 'gj')
vim.keymap.set('n', 'k', 'gk')

-- Map for Escape key in terminal
vim.keymap.set('t', '<Leader>jj', '<C-\\><C-n>')

local mapping_group = vim.api.nvim_create_augroup('vimrc_terminal_mappings', { clear = true })
vim.api.nvim_create_autocmd('TermOpen', {
  pattern = '*',
  callback = function()
    -- Focus first file:line:col pattern in the terminal output
    vim.keymap.set('n', 'F', [[:call search('\f\+:\d\+:\d\+')<CR>]], { buffer = true, silent = true })
    vim.bo.bufhidden = 'wipe'
  end,
  group = mapping_group,
})

-- Copy to system clipboard
vim.keymap.set('v', '<C-c>', '"+y')
-- Paste from system clipboard with Ctrl + v
vim.keymap.set('i', '<C-v>', '<Esc>"+p')
vim.keymap.set('n', '<Leader>p', '"0p')
vim.keymap.set('v', '<Leader>p', '"0p')
vim.keymap.set('n', '<Leader>h', 'viw"0p', { nowait = false })

-- Move to the end of yanked text after yank and paste
vim.keymap.set('n', 'p', 'p`]')
vim.keymap.set('v', 'y', 'y`]')
vim.keymap.set('v', 'p', 'p`]')
-- Select last pasted text
vim.keymap.set('n', 'gp', "'`[' . strpart(getregtype(), 0, 1) . '`]'", { expr = true })

-- Move selected lines up and down
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")

-- Toggle between last 2 buffers
vim.keymap.set('n', '<leader><tab>', '<c-^>')

-- Indenting in visual mode
vim.keymap.set('x', '<s-tab>', '<gv')
vim.keymap.set('x', '<tab>', '>gv')

-- Resize window with shift + and shift -
vim.keymap.set('n', '_', '<c-w>5<')
vim.keymap.set('n', '+', '<c-w>5>')

-- Disable ex mode mapping
vim.keymap.set('', 'Q', '<c-z>', { remap = true })

-- Jump to definition in vertical split
vim.keymap.set('n', '<Leader>]', '<C-W>v<C-]>')

-- Close all other buffers except current one
vim.keymap.set('n', '<Leader>db', ':silent w <BAR> :silent %bd <BAR> e#<CR>')

-- Unimpaired mappings
vim.keymap.set('n', '[q', ':cprevious<CR>')
vim.keymap.set('n', ']q', ':cnext<CR>')
vim.keymap.set('n', '[Q', ':cfirst<CR>')
vim.keymap.set('n', ']Q', ':clast<CR>')
vim.keymap.set('n', '[e', ':lprevious<CR>')
vim.keymap.set('n', ']e', ':lnext<CR>')
vim.keymap.set('n', '[L', ':lfirst<CR>')
vim.keymap.set('n', ']L', ':llast<CR>')
vim.keymap.set('n', '[t', ':tprevious<CR>')
vim.keymap.set('n', ']t', ':tnext<CR>')
vim.keymap.set('n', '[T', ':tfirst<CR>')
vim.keymap.set('n', ']T', ':tlast<CR>')
vim.keymap.set('n', '[b', ':bprevious<CR>')
vim.keymap.set('n', ']b', ':bnext<CR>')
vim.keymap.set('n', '[B', ':bfirst<CR>')
vim.keymap.set('n', ']B', ':blast<CR>')

--rsi mappings
vim.keymap.set('c', '<C-a>', '<Home>')
vim.keymap.set('c', '<C-e>', '<End>')
vim.keymap.set('c', '<C-b>', '<End>')
vim.keymap.set('c', '<C-j>', 'wildmenumode() ? "<c-j>" : "<down>"', { expr = true })
vim.keymap.set('c', '<C-k>', 'wildmenumode() ? "<c-k>" : "<up>"', { expr = true })

vim.keymap.set('n', '<leader>T', ':call v:lua.kris.mappings.toggle_terminal()<CR>')
vim.keymap.set('t', '<leader>T', '<C-\\><C-n><C-w>c')

vim.keymap.set('n', 'gs', ':%s/')
vim.keymap.set('x', 'gs', ':s/')

vim.keymap.set('n', 'gx', function()
  vim.cmd([[
    unlet! g:loaded_netrw
    unlet! g:loaded_netrwPlugin
    runtime! plugin/netrwPlugin.vim
  ]])
  return vim.fn['netrw#BrowseX'](vim.fn.expand('<cfile>'), vim.fn['netrw#CheckIfRemote']())
end, { silent = true })

-- Taken from https://gist.github.com/romainl/c0a8b57a36aec71a986f1120e1931f20
for _, char in ipairs({ '_', '.', ':', ',', ';', '<bar>', '/', '<bslash>', '*', '+', '-', '#' }) do
  vim.keymap.set('x', 'i' .. char, ':<C-u>normal! T' .. char .. 'vt' .. char .. '<CR>')
  vim.keymap.set('o', 'i' .. char, ':normal vi' .. char .. '<CR>')
  vim.keymap.set('x', 'a' .. char, ':<C-u>normal! F' .. char .. 'vf' .. char .. '<CR>')
  vim.keymap.set('o', 'a' .. char, ':normal va' .. char .. '<CR>')
end

local function close_buffer(bang)
  if vim.bo.buftype ~= '' then
    return vim.cmd('q!')
  end

  local windowCount = vim.fn.winnr('$')
  local totalBuffers = #vim.fn.getbufinfo({ buflisted = 1 })
  local noSplits = windowCount == 1
  bang = bang and '!' or ''
  if totalBuffers > 1 and noSplits then
    local command = 'bp'
    if vim.fn.buflisted(vim.fn.bufnr('#')) then
      command = command .. '|bd' .. bang .. '#'
    end
    return vim.cmd(command)
  end
  return vim.cmd('q' .. bang)
end

local function open_file_on_line_and_column()
  local path = vim.fn.expand('<cfile>')
  local line = vim.fn.getline('.')
  local row = 1
  local col = 1
  if vim.fn.match(line, vim.fn.escape(path, '/') .. ':\\d*:\\d*') > -1 then
    local matchlist = vim.fn.matchlist(line, vim.fn.escape(path, '/') .. ':\\(\\d*\\):\\(\\d*\\)')
    row = matchlist[2] or 1
    col = matchlist[3] or 1
  end

  local bufnr = vim.fn.bufnr(path)
  local winnr = vim.fn.bufwinnr(bufnr)
  if winnr > -1 and vim.fn.getbufvar(bufnr, '&buftype') ~= 'terminal' then
    vim.cmd(winnr .. 'wincmd w')
  else
    vim.cmd('vsplit ' .. path)
  end
  vim.fn.cursor(row, col)
end

local function open_file_or_create_new()
  local path = vim.fn.expand('<cfile>')
  if not path or path == '' then
    return false
  end

  if vim.bo.buftype == 'terminal' then
    return open_file_on_line_and_column()
  end

  if pcall(vim.cmd, 'norm!gf') then
    return true
  end

  vim.api.nvim_out_write('New file.\n')
  local new_path = vim.fn.fnamemodify(vim.fn.expand('%:p:h') .. '/' .. path, ':p')
  local ext = vim.fn.fnamemodify(new_path, ':e')

  if ext and ext ~= '' then
    return vim.cmd('edit ' .. new_path)
  end

  local suffixes = vim.fn.split(vim.bo.suffixesadd, ',')

  for _, suffix in ipairs(suffixes) do
    if vim.fn.filereadable(new_path .. suffix) then
      return vim.cmd('edit ' .. new_path .. suffix)
    end
  end

  return vim.cmd('edit ' .. new_path .. suffixes[1])
end

vim.cmd([[command! Json call v:lua.kris.mappings.paste_to_json_buffer()]])

vim.keymap.set('n', 'gF', open_file_or_create_new)
vim.keymap.set('n', '<Leader>q', function()
  return close_buffer()
end)
vim.keymap.set('n', '<Leader>Q', function()
  return close_buffer(true)
end)

function mappings.paste_to_json_buffer()
  vim.cmd([[vsplit]])
  vim.cmd([[enew]])
  vim.bo.filetype = 'json'
  vim.cmd([[norm!"+p]])
  vim.cmd([[norm!VGgq]])
end

local terminal_bufnr = 0
function mappings.toggle_terminal(close)
  if close then
    terminal_bufnr = 0
    return
  end
  if terminal_bufnr <= 0 then
    vim.api.nvim_create_autocmd('TermOpen', {
      pattern = '*',
      command = 'startinsert',
      once = true,
    })
    vim.cmd([[sp | term]])
    vim.cmd([[setlocal bufhidden=hide]])
    vim.api.nvim_create_autocmd('BufDelete', {
      pattern = '<buffer>',
      callback = function()
        mappings.toggle_terminal(true)
      end,
    })
    terminal_bufnr = vim.api.nvim_get_current_buf()
    return
  end

  local win = vim.fn.bufwinnr(terminal_bufnr)

  if win > -1 then
    vim.cmd(win .. 'close')
    return
  end

  vim.cmd('sp | b' .. terminal_bufnr .. ' | startinsert')
end

_G.kris.mappings = mappings
