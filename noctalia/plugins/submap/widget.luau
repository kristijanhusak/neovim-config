local is_sway = noctalia.getenv('SWAYSOCK') or false
local cmd = 'hyprctl submap'
if is_sway then
  cmd = [[swaymsg -r -t get_binding_state | jq -r '.name // "default"']]
end

barWidget.setColor('error')

function onIpc(event)
  if event ~= 'refresh' then
    return
  end

  noctalia.runAsync(cmd, function(result)
    if result.stdout and result.stdout ~= 'default' then
      barWidget.setText(string.upper(result.stdout))
    else
      barWidget.setText('')
    end
  end)
end
