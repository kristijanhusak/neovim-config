local separator = '>>>>>'

local function run(force)
  noctalia.runAsync('~/.config/noctalia/scripts/exchangerates.sh'..(force and ' --force' or ''), function(result)
    local parts = {}
    for part in string.gmatch(result.stdout .. separator, '(.-)' .. separator) do
      local trim_part = part:gsub('^%s*', ''):gsub('%s*$', '')
      table.insert(parts, trim_part)
    end
    barWidget.setText(parts[1])
    barWidget.setTooltip(parts[2])
  end)
end

run()


function onRightClick()
  run(true)
end
