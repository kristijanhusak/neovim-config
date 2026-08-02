--!nonstrict

local USD_URL = 'https://kurs.resenje.org/api/v1/currencies/USD/rates/today'
local EUR_URL = 'https://kurs.resenje.org/api/v1/currencies/EUR/rates/today'
local CACHE_FILE = 'rates.json'
local CACHE_HOUR = 9
local STATE_KEY = 'exchange_rates.data'

local cache = { version = 1, rates = {} }
local cachePath = nil
local fetchInFlight = false
local refreshPending = false

local function currentDate()
  return noctalia.formatTime('%F')
end

local function currentTime()
  return noctalia.formatTime('%H:%M')
end

local function latestRate()
  return cache.rates[#cache.rates]
end

local function todaysRate()
  local today = currentDate()
  for index = #cache.rates, 1, -1 do
    local entry = cache.rates[index]
    if entry.date == today then
      return entry
    end
  end
  return nil
end

local function history()
  local previousRates = {}
  local today = currentDate()
  for _, entry in ipairs(cache.rates) do
    if entry.date ~= today then
      table.insert(previousRates, entry)
    end
  end

  local first = math.max(1, #previousRates - 6)
  local recent = {}
  for index = first, #previousRates do
    table.insert(recent, previousRates[index])
  end
  return recent
end

local function publish(rate)
  noctalia.state.set(STATE_KEY, {
    current = rate,
    history = history(),
  })
end

local function isFresh(rate)
  if rate == nil then
    return false
  end

  local hour, minute = rate.time:match('^(%d%d):(%d%d)$')
  hour = tonumber(hour)
  minute = tonumber(minute)
  return hour ~= nil and minute ~= nil and (hour > CACHE_HOUR or (hour == CACHE_HOUR and minute >= 0))
end

local function normalizeRate(rate)
  if tonumber(rate) == nil then
    return nil
  end
  return tostring(rate)
end

local function loadCache()
  local dataDir, dataDirError = noctalia.pluginDataDir()
  if dataDir == nil then
    noctalia.log('Exchange rates: unable to access plugin data directory: ' .. (dataDirError or 'unknown error'))
    return
  end

  cachePath = dataDir .. '/' .. CACHE_FILE
  if not noctalia.fileExists(cachePath) then
    return
  end

  local contents, readError = noctalia.readFile(cachePath)
  if contents == nil then
    noctalia.log('Exchange rates: unable to read cache: ' .. (readError or 'unknown error'))
    return
  end

  local decoded, decodeError = noctalia.json.decode(contents)
  if type(decoded) ~= 'table' or type(decoded.rates) ~= 'table' then
    noctalia.log('Exchange rates: invalid cache JSON: ' .. (decodeError or 'missing rates array'))
    return
  end

  for _, entry in ipairs(decoded.rates) do
    if
      type(entry) == 'table'
      and type(entry.date) == 'string'
      and type(entry.time) == 'string'
      and normalizeRate(entry.usd) ~= nil
      and normalizeRate(entry.eur) ~= nil
    then
      entry.usd = normalizeRate(entry.usd)
      entry.eur = normalizeRate(entry.eur)
      table.insert(cache.rates, entry)
    end
  end
end

local function saveCache()
  if cachePath == nil then
    return
  end

  local encoded, encodeError = noctalia.json.encode(cache, true)
  if encoded == nil then
    noctalia.log('Exchange rates: unable to encode cache: ' .. (encodeError or 'unknown error'))
    return
  end

  local ok, writeError = noctalia.writeFile(cachePath, encoded)
  if not ok then
    noctalia.log('Exchange rates: unable to write cache: ' .. (writeError or 'unknown error'))
  end
end

local function requestRate(url, onResult)
  local started = noctalia.http({ url = url }, function(response)
    if not response.ok or response.status < 200 or response.status >= 300 then
      onResult(nil)
      return
    end

    local rate = nil
    local decoded, decodeError = noctalia.json.decode(response.body)
    if type(decoded) == 'table' then
      rate = decoded.exchange_middle
    end

    if normalizeRate(rate) == nil then
      onResult(nil)
      return
    end
    onResult(rate)
  end)
  if not started then
    onResult(nil)
  end
end

local function refresh(force)
  if fetchInFlight then
    refreshPending = refreshPending or force
    return
  end

  local cachedToday = todaysRate()
  if not force and isFresh(cachedToday) then
    publish(cachedToday)
    return
  end

  fetchInFlight = true
  local rates = {}
  local complete = 0

  local function finish()
    complete += 1
    if complete < 2 then
      return
    end

    fetchInFlight = false
    if rates.usd == nil or rates.eur == nil then
      local previous = latestRate()
      publish(previous)
      if previous == nil then
        noctalia.notifyError('Exchange rates', 'Failed to fetch exchange rates and no cached value is available.')
      else
        noctalia.notifyError(
          'Exchange rates',
          'Failed to fetch exchange rates. Using cached value from ' .. previous.date .. '.'
        )
      end
    else
      local previous = cachedToday or latestRate()
      local entry = {
        date = currentDate(),
        time = currentTime(),
        usd = rates.usd,
        eur = rates.eur,
      }

      if cachedToday ~= nil then
        for index = #cache.rates, 1, -1 do
          if cache.rates[index].date == entry.date then
            table.remove(cache.rates, index)
          end
        end
      end
      table.insert(cache.rates, entry)
      saveCache()
      publish(entry)

      if
        previous ~= nil
        and (force or tonumber(previous.usd) ~= tonumber(entry.usd) or tonumber(previous.eur) ~= tonumber(entry.eur))
      then
        noctalia.notify(
          'Exchange rates',
          ('USD: %s -> %s\nEUR: %s -> %s'):format(
            tostring(previous.usd),
            tostring(entry.usd),
            tostring(previous.eur),
            tostring(entry.eur)
          )
        )
      end
    end

    if refreshPending then
      refreshPending = false
      refresh(true)
    end
  end

  requestRate(USD_URL, function(rate)
    rates.usd = rate
    finish()
  end)
  requestRate(EUR_URL, function(rate)
    rates.eur = rate
    finish()
  end)
end

function update()
  refresh(false)
end

noctalia.state.watch('exchange_rates.refresh', function(force)
  if force then
    noctalia.state.set('exchange_rates.refresh', nil)
    refresh(true)
  end
end)

noctalia.setUpdateInterval(60 * 60 * 1000)
loadCache()
publish(latestRate())
refresh(false)
