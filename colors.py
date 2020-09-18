import pynvim
nvim = pynvim.attach('child', argv=["/bin/env", "nvim", "--embed", "--headless"])
nvim.command('source /home/kristijan/.config/nvim/pack/packager/start/gruvbox/colors/gruvbox.vim')

def get_hl_color(name):
    hl_output = nvim.call('execute', 'hi ' + name)
    bg = None
    fg = None
    for item in hl_output.split('\n')[1].split():
        if item.startswith('guifg'):
            fg = item.split('=')[1]
        if item.startswith('guibg'):
            bg = item.split('=')[1]
    return fg, bg

normal_fg, normal_bg = get_hl_color('Normal')
cursor_fg, cursor_bg = get_hl_color('Cursor')
selection_fg, selection_bg = get_hl_color('Visual')

command = [
    'kitty @ set-colors',
    'foreground=' + normal_fg,
    'background=' + normal_bg,
    'cursor=' + (cursor_bg or normal_fg),
    'cursor_text_color=' + (cursor_fg or normal_bg),
    'selection_foreground=' + (selection_fg or normal_bg),
    'selection_background=' + (selection_bg or normal_fg)
]
for i in range(0, 15):
    command.append('color' + str(i) + '=' + nvim.eval('g:terminal_color_' + str(i)))

print(' '.join(command))
nvim.close()

