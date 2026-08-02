--!nonstrict

local STATE_KEY = 'exchange_rates.data'
local data = nil

local function formatRate(rate)
  local value = tostring(rate)
  local decimal = value:match('%.(%d+)$')
  if decimal == nil then
    return value .. '.000'
  end
  return value .. string.rep('0', math.max(0, 3 - #decimal))
end

local function shortDate(date)
  local year, month, day = date:match('^(%d%d%d%d)%-(%d%d)%-(%d%d)$')
  if year == nil then
    return date
  end
  return day .. '.' .. month .. '.' .. year
end

local function rateCard(currency, value)
  local glyph = currency == 'USD' and 'currency-dollar' or 'currency-euro'
  return ui.column({
    flexGrow = 1,
    gap = 4,
    padding = 12,
    radius = 8,
    fill = 'surface_variant/0.45',
  }, {
    ui.row({ align = 'center', gap = 4 }, {
      ui.glyph({ name = glyph, size = 16, color = 'on_surface_variant' }),
      ui.label({ text = currency, fontSize = 12, color = 'on_surface_variant' }),
    }),
    ui.label({ text = formatRate(value), fontSize = 22, fontWeight = 'bold', color = 'primary' }),
  })
end

local function historyRow(date, usd, eur, alternate)
  return ui.row({
    align = 'center',
    gap = 12,
    paddingH = 8,
    paddingV = 6,
    fill = alternate and 'surface_variant/0.25' or 'surface/0',
  }, {
    ui.label({ text = date, color = 'on_surface_variant', fontSize = 12, flexGrow = 1 }),
    ui.label({ text = formatRate(usd), fontSize = 12, flexGrow = 1 }),
    ui.label({ text = formatRate(eur), flexGrow = 1, fontSize = 12 }),
  })
end

local function render()
  local content = {}
  if type(data) ~= 'table' or type(data.current) ~= 'table' then
    table.insert(
      content,
      ui.label({
        text = 'Exchange-rate data is unavailable.',
        color = 'on_surface_variant',
        fontSize = 13,
      })
    )
  else
    local current = data.current
    table.insert(
      content,
      ui.row({ gap = 8 }, {
        rateCard('USD', current.usd),
        rateCard('EUR', current.eur),
      })
    )

    table.insert(
      content,
      ui.separator({
        thickness = 2,
        spacing = 10,
      })
    )

    table.insert(
      content,
      ui.label({
        text = 'Exchange-rate history (last 7 days)',
        fontWeight = 'bold',
        height = 50,
      })
    )
    table.insert(
      content,
      ui.separator({
        thickness = 0,
        spacing = 2,
      })
    )

    local tableRows = {}
    table.insert(
      tableRows,
      ui.row({
        align = 'center',
        gap = 12,
        paddingH = 8,
        paddingV = 6,
        radius = 6,
        fill = 'surface_variant/0.65',
      }, {
        ui.label({ text = 'Date', fontSize = 12, fontWeight = 'bold', flexGrow = 1 }),
        ui.label({ text = 'USD', fontSize = 12, fontWeight = 'bold', flexGrow = 1 }),
        ui.label({ text = 'EUR', fontSize = 12, fontWeight = 'bold', flexGrow = 1 }),
      })
    )
    for index, entry in ipairs(data.history or {}) do
      table.insert(tableRows, historyRow(shortDate(entry.date), entry.usd, entry.eur, index % 2 == 0))
    end
    table.insert(content, ui.column({ gap = 0, align = 'stretch' }, tableRows))
  end

  local footer = ui.row({ justify = 'end' }, {})
  if type(data) == 'table' and type(data.current) == 'table' then
    footer = ui.row({ justify = 'end' }, {
      ui.label({
        text = 'Updated ' .. data.current.date .. ' at ' .. data.current.time,
        fontSize = 12,
        color = 'on_surface_variant',
      }),
    })
  end

  panel.render(ui.column({ flexGrow = 1, gap = 8, padding = 12, align = 'stretch' }, {
    ui.row({ align = 'center', justify = 'space_between' }, {
      ui.label({
        text = 'Exchange rates (' .. noctalia.formatTime('%d.%m.%Y') .. ')',
        fontSize = 18,
        fontWeight = 'bold',
        flexGrow = 1,
      }),
      ui.button({
        glyph = 'refresh',
        variant = 'ghost',
        tooltip = 'Refresh rates',
        onClick = function()
          noctalia.state.set('exchange_rates.refresh', true)
        end,
      }),
      ui.button({
        glyph = 'close',
        variant = 'ghost',
        tooltip = 'Close',
        onClick = function()
          panel.close()
        end,
      }),
    }),
    ui.column({ flexGrow = 1, gap = 4, align = 'stretch' }, content),
    footer,
  }))
end

function onOpen(_context)
  data = noctalia.state.get(STATE_KEY)
  render()
end

noctalia.state.watch(STATE_KEY, function(value)
  data = value
  render()
end)
