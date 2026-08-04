local mod = 'ALT'
local i3 = require('i3')
local hy3 = hl.plugin.hy3

local noctalia = function(cmd)
  return 'noctalia msg ' .. cmd
end

i3.setup()

hl.config({
  general = {
    border_size = 2,
    gaps_in = 4,
    gaps_out = 4,
    layout = 'hy3',
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
  output = '',
  mode = 'highrr',
  position = 'auto',
  scale = 1,
})

hl.window_rule({
  name = 'hide_solo_border',
  match = {
    workspace = 'w[t1]',
    float = false,
  },
  border_size = 0,
  rounding = 0,
})

hl.window_rule({
  name = 'hide_fullscreen_border',
  match = {
    workspace = 'f[1]',
    float = false,
  },
  border_size = 0,
  rounding = 0,
})

hl.on('hyprland.start', function()
  local startup = {
    'hyprpm reload -n',
    'noctalia',
    'dropbox',
    'kanata',
    '~/.config/hypr/events.sh',
  }

  for _, cmd in ipairs(startup) do
    hl.exec_cmd(cmd)
  end
end)

hl.bind(mod .. ' + Return', hl.dsp.exec_cmd('kitty'))
hl.bind(mod .. ' + b', hl.dsp.exec_cmd('firefox'))
hl.bind(mod .. ' + d', hl.dsp.exec_cmd(noctalia('panel-toggle launcher')))
hl.bind(mod .. ' + t', hl.dsp.exec_cmd(noctalia('panel-toggle launcher /win')))
hl.bind(mod .. ' + SHIFT + i', hl.dsp.window.float({ action = 'toggle' }))

hl.bind(
  mod .. ' + SHIFT + e',
  hl.dsp.exec_cmd([[zenity --question --text="Do you really want to exit Hyprland?" && hyprctl dispatch exit]])
)
hl.bind(mod .. ' + SHIFT + c', hl.dsp.exec_cmd('hyprctl reload'))

hl.bind(mod .. ' + q', hl.dsp.window.close())
hl.bind(mod .. ' + f', hl.dsp.window.fullscreen_state({ internal = 1, client = 1, action = 'toggle' }))
hl.bind(mod .. ' + h', hy3.move_focus('l'))
hl.bind(mod .. ' + j', hy3.move_focus('d'))
hl.bind(mod .. ' + k', hy3.move_focus('u'))
hl.bind(mod .. ' + l', hy3.move_focus('r'))
hl.bind(mod .. ' + left', hy3.move_focus('l'))
hl.bind(mod .. ' + down', hy3.move_focus('d'))
hl.bind(mod .. ' + up', hy3.move_focus('u'))
hl.bind(mod .. ' + right', hy3.move_focus('r'))

hl.bind(mod .. ' + SHIFT + h', hy3.move_window('l'))
hl.bind(mod .. ' + SHIFT + j', hy3.move_window('d'))
hl.bind(mod .. ' + SHIFT + k', hy3.move_window('u'))
hl.bind(mod .. ' + SHIFT + l', hy3.move_window('r'))
hl.bind(mod .. ' + SHIFT + left', hy3.move_window('l'))
hl.bind(mod .. ' + SHIFT + down', hy3.move_window('d'))
hl.bind(mod .. ' + SHIFT + up', hy3.move_window('u'))
hl.bind(mod .. ' + SHIFT + right', hy3.move_window('r'))

hl.bind(mod .. ' + n', function()
  hl.dispatch(hy3.make_group('h', { toggle = true, ephemeral = true }))
  hl.exec_cmd([[hyprctl notify 0 2000 "rgb(ffffff)" "Split vertical"]])
end)
hl.bind(mod .. ' + o', function()
  hl.dispatch(hy3.make_group('v', { toggle = true, ephemeral = true }))
  hl.exec_cmd([[hyprctl notify 0 2000 "rgb(ffffff)" "Split horizontal"]])
end)
hl.bind(mod .. ' + w', hy3.change_group('tab'))
hl.bind(mod .. ' + e', hy3.change_group('untab'))

for i = 1, 9 do
  hl.bind(mod .. ' + ' .. i, hl.dsp.focus({ workspace = i }))
  hl.bind(mod .. ' + SHIFT + ' .. i, hy3.move_to_workspace(i))
end

hl.bind(mod .. ' + EQUAL', hl.dsp.window.resize({ x = 10, y = 0, relative = true }), { repeating = true })
hl.bind(mod .. ' + minus', hl.dsp.window.resize({ x = -10, y = 0, relative = true }), { repeating = true })
hl.bind(mod .. ' + SHIFT + w', hy3.equalize({ scope = 'workspace' }))

hl.bind(mod .. ' + mouse:272', hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. ' + mouse:273', hl.dsp.window.resize(), { mouse = true })

hl.bind(mod .. ' + r', hl.dsp.submap('resize'))
hl.define_submap('resize', function()
  hl.bind('h', hl.dsp.window.resize({ x = -10, y = 0, relative = true }), { repeating = true })
  hl.bind('j', hl.dsp.window.resize({ x = 0, y = 10, relative = true }), { repeating = true })
  hl.bind('k', hl.dsp.window.resize({ x = 0, y = -10, relative = true }), { repeating = true })
  hl.bind('l', hl.dsp.window.resize({ x = 10, y = 0, relative = true }), { repeating = true })
  hl.bind('Return', hl.dsp.submap('reset'))
  hl.bind('Escape', hl.dsp.submap('reset'))
end)

hl.bind('CTRL + ' .. mod .. ' + l', hl.dsp.exec_cmd(noctalia('session lock')))

hl.bind('XF86AudioRaiseVolume', hl.dsp.exec_cmd(noctalia('volume-up 1')))
hl.bind('XF86AudioLowerVolume', hl.dsp.exec_cmd(noctalia('volume-down 1')))
hl.bind('XF86AudioMute', hl.dsp.exec_cmd(noctalia('volume-mute')))
hl.bind('XF86AudioPlay', hl.dsp.exec_cmd(noctalia('media toggle')))
hl.bind('XF86AudioNext', hl.dsp.exec_cmd(noctalia('media next')))
hl.bind('XF86AudioPrev', hl.dsp.exec_cmd(noctalia('media previous')))

hl.bind('Print', hl.dsp.exec_cmd(noctalia('screenshot-region')))
hl.bind(mod .. ' + CTRL + r', hl.dsp.exec_cmd(noctalia('plugin noctalia/screen_recorder:service all start')))
hl.bind(mod .. ' + CTRL + s', hl.dsp.exec_cmd(noctalia('plugin noctalia/screen_recorder:service all stop')))

hl.window_rule({
  name = 'calculator',
  match = {
    class = '^(org.gnome.Calculator)$',
  },
  float = true,
})

hl.window_rule({
  name = 'junction',
  match = {
    title = '^(Junction)$',
  },
  float = true,
  focus_on_activate = true,
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
    class = '^(viber)$',
  },
  workspace = '6',
})

hl.workspace_rule({
  workspace = 'w[tv1]',
  gaps_out = 0,
  gaps_in = 0,
})
--
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

hl.window_rule({
  match = {
    float = true,
  },
  center = true,
  max_size = { 'monitor_w * 0.6', 'monitor_h * 0.6' },
})
