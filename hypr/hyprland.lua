local mod = 'ALT'
local ipc = 'qs -c noctalia-shell ipc call'
local i3 = require('i3')

i3.setup()

hl.config({
  general = {
    border_size = 2,
    gaps_in = 4,
    gaps_out = 4,
    layout = 'lua:i3',
    col = {
      active_border = 'rgba(00ffffff)',
    },
  },

  input = {
    kb_layout = 'us,rs(latin),rs',
    kb_options = 'grp:lctrl_lwin_toggle',
    repeat_delay = 350,
    repeat_rate = 60,
    follow_mouse = 2,
  },

  decoration = {
    rounding = 6,
    active_opacity = 1.0,
    inactive_opacity = 1.0,
    fullscreen_opacity = 1.0,
  },

  animations = {
    enabled = false,
  },
})

hl.monitor({
  output = 'DP-1',
  mode = '3440x1440@144',
  position = '0x0',
  scale = 1,
})

hl.window_rule({
  name = 'hide_solo_border',
  match = {
    workspace = 'w[t1]',
  },
  border_size = 0,
  rounding = 0,
})

hl.window_rule({
  name = 'hide_fullscreen_border',
  match = {
    workspace = 'f[1]',
  },
  border_size = 0,
  rounding = 0,
})

hl.on('hyprland.start', function()
  local startup = {
    'hyprpm reload -n',
    '/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1',
    'google-chrome-stable',
    'kitty',
    'dropbox',
    'qs -c noctalia-shell',
    '~/.config/hypr/events.sh',
  }

  for _, cmd in ipairs(startup) do
    hl.exec_cmd(cmd)
  end
end)

hl.bind(mod .. ' + Return', hl.dsp.exec_cmd('kitty'))
hl.bind(mod .. ' + b', hl.dsp.exec_cmd('google-chrome-stable'))
hl.bind(mod .. ' + d', hl.dsp.exec_cmd(ipc .. ' launcher toggle'))
hl.bind(mod .. ' + SHIFT + i', hl.dsp.window.float({ action = 'toggle' }))

hl.bind(
  mod .. ' + SHIFT + e',
  hl.dsp.exec_cmd([[zenity --question --text="Do you really want to exit Hyprland?" && hyprctl dispatch exit]])
)
hl.bind(mod .. ' + SHIFT + c', hl.dsp.exec_cmd('hyprctl reload'))

hl.bind(mod .. ' + q', hl.dsp.window.close())
hl.bind(mod .. ' + f', hl.dsp.window.fullscreen_state({ internal = 1, client = 1, action = 'toggle' }))
hl.bind(mod .. ' + h', hl.dsp.layout('focus l'))
hl.bind(mod .. ' + j', hl.dsp.layout('focus d'))
hl.bind(mod .. ' + k', hl.dsp.layout('focus u'))
hl.bind(mod .. ' + l', hl.dsp.layout('focus r'))
hl.bind(mod .. ' + left', hl.dsp.layout('focus l'))
hl.bind(mod .. ' + down', hl.dsp.layout('focus d'))
hl.bind(mod .. ' + up', hl.dsp.layout('focus u'))
hl.bind(mod .. ' + right', hl.dsp.layout('focus r'))

hl.bind(mod .. ' + SHIFT + h', hl.dsp.window.move({ direction = 'l' }))
hl.bind(mod .. ' + SHIFT + j', hl.dsp.window.move({ direction = 'd' }))
hl.bind(mod .. ' + SHIFT + k', hl.dsp.window.move({ direction = 'u' }))
hl.bind(mod .. ' + SHIFT + l', hl.dsp.window.move({ direction = 'r' }))
hl.bind(mod .. ' + SHIFT + left', hl.dsp.window.move({ direction = 'l' }))
hl.bind(mod .. ' + SHIFT + down', hl.dsp.window.move({ direction = 'd' }))
hl.bind(mod .. ' + SHIFT + up', hl.dsp.window.move({ direction = 'u' }))
hl.bind(mod .. ' + SHIFT + right', hl.dsp.window.move({ direction = 'r' }))

hl.bind(mod .. ' + n', hl.dsp.layout('split vertical'))
hl.bind(mod .. ' + o', hl.dsp.layout('split horizontal'))
hl.bind(mod .. ' + t', hl.dsp.layout('split toggle'))

for i = 1, 9 do
  hl.bind(mod .. ' + ' .. i, hl.dsp.focus({ workspace = i }))
  hl.bind(mod .. ' + SHIFT + ' .. i, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mod .. ' + EQUAL', hl.dsp.layout('colresize +0.025'))
hl.bind(mod .. ' + minus', hl.dsp.layout('colresize -0.025'))
hl.bind(mod .. ' + SHIFT + w', hl.dsp.layout('fit all'))

hl.bind(mod .. ' + mouse:272', hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. ' + mouse:273', hl.dsp.window.resize(), { mouse = true })

hl.bind(
  'Print',
  hl.dsp.exec_cmd(
    [[sh -c 'sleep 0.2 && grim -g "$(slurp)" ~/Pictures/screenshots/screenshot_$(date +%Y_%m_%d_%H_%M_%S).png']]
  )
)

hl.bind(mod .. ' + r', hl.dsp.submap('resize'))

hl.define_submap('resize', 'reset', function()
  hl.bind('h', hl.dsp.window.resize({ x = -20, y = 0, relative = true }))
  hl.bind('j', hl.dsp.window.resize({ x = 0, y = 20, relative = true }))
  hl.bind('k', hl.dsp.window.resize({ x = 0, y = -20, relative = true }))
  hl.bind('l', hl.dsp.window.resize({ x = 20, y = 0, relative = true }))
  hl.bind('Return', hl.dsp.submap('reset'))
  hl.bind('Escape', hl.dsp.submap('reset'))
end)

hl.bind('CTRL + ' .. mod .. ' + l', hl.dsp.exec_cmd(ipc .. ' lockScreen lock'))

hl.bind('XF86AudioRaiseVolume', hl.dsp.exec_cmd(ipc .. ' volume increase'))
hl.bind('XF86AudioLowerVolume', hl.dsp.exec_cmd(ipc .. ' volume decrease'))
hl.bind('XF86AudioMute', hl.dsp.exec_cmd(ipc .. ' volume muteOutput'))
hl.bind('XF86AudioPlay', hl.dsp.exec_cmd(ipc .. ' media playPause'))

hl.bind(mod .. ' + CTRL + r', hl.dsp.exec_cmd('~/.config/hypr/record_screen.sh --start'))
hl.bind(mod .. ' + CTRL + s', hl.dsp.exec_cmd('~/.config/hypr/record_screen.sh --stop'))

hl.window_rule({
  name = 'calculator',
  match = {
    class = '^(org.gnome.Calculator)$',
  },
  float = true,
})

hl.window_rule({
  name = 'chrome-save-file',
  match = {
    class = '^(google-chrome)$',
    title = '^(Save File)$',
  },
  float = true,
})

hl.window_rule({
  name = 'thunar-rename-file',
  match = {
    class = '^(thunar)$',
    title = '^(Rename.*)$',
  },
  float = true,
})

hl.window_rule({
  name = 'thunar-file-operation',
  match = {
    class = '^(thunar)$',
    title = '^(File Operation Progress)$',
  },
  float = true,
})

hl.window_rule({
  name = 'chrome-native-notification',
  match = {
    class = '^$',
    title = '^$',
  },
  float = true,
  pin = true,
  move = '((monitor_w*1)-370) ((10))',
  no_initial_focus = true,
})

hl.window_rule({
  name = 'viber-notifications',
  match = {
    title = '^(ViberPC)$',
  },
  float = true,
  no_initial_focus = true,
  pin = true,
  move = '((monitor_w*1)) ((monitor_h*1))',
})

hl.window_rule({
  name = 'rofi-focus',
  match = {
    class = '^(rofi)$',
  },
  stay_focused = true,
})

hl.window_rule({
  name = 'workspace-2',
  match = {
    class = '^(google-chrome|firefox|Brave-browser)$',
  },
  workspace = '2',
})

hl.window_rule({
  name = 'workspace-4',
  match = {
    class = 'slack',
  },
  workspace = '4',
})

hl.window_rule({
  name = 'workspace-6',
  match = {
    class = '^(ViberPC)$',
  },
  workspace = '6',
})

hl.workspace_rule({
  workspace = 'w[tv1]',
  gaps_out = 0,
  gaps_in = 0,
})

hl.workspace_rule({
  workspace = 'f[1]',
  gaps_out = 0,
  gaps_in = 0,
})

hl.window_rule({
  name = 'smart-gaps-wtv1-border',
  match = {
    float = false,
    workspace = 'w[tv1]',
  },
  border_size = 0,
})

hl.window_rule({
  name = 'smart-gaps-wtv1-rounding',
  match = {
    float = false,
    workspace = 'w[tv1]',
  },
  rounding = 0,
})

hl.window_rule({
  name = 'smart-gaps-f1-border',
  match = {
    float = false,
    workspace = 'f[1]',
  },
  border_size = 0,
})

hl.window_rule({
  name = 'smart-gaps-f1-rounding',
  match = {
    float = false,
    workspace = 'f[1]',
  },
  rounding = 0,
})
