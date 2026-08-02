--!nonstrict

local STATE_KEY = 'exchange_rates.data'

local function formatRate(rate)
  local value = tostring(rate)
  local decimal = value:match('%.(%d+)$')
  if decimal == nil then
    return value .. '.000'
  end
  return value .. string.rep('0', math.max(0, 3 - #decimal))
end

local function render(data)
  barWidget.clearTooltip()
  barWidget.setGlyph('currency-dollar')

  if type(data) ~= 'table' or type(data.current) ~= 'table' then
    barWidget.setText('--')
    return
  end

  barWidget.setText(formatRate(data.current.usd))
end

function onClick()
  noctalia.togglePanel('me/exchange_rates:panel')
end

function onRightClick()
  noctalia.state.set('exchange_rates.refresh', true)
end

noctalia.state.watch(STATE_KEY, render)
render(noctalia.state.get(STATE_KEY))
