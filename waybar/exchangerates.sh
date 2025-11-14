#!/bin/sh
CACHE_FILE="$HOME/.local/share/exchange_rate_cache"
USD_URL="https://kurs.resenje.org/api/v1/currencies/USD/rates/today"
EUR_URL="https://kurs.resenje.org/api/v1/currencies/EUR/rates/today"

if [ ! -f "$CACHE_FILE" ]; then
    touch "$CACHE_FILE"
fi

force=0
if [ "$1" = "--force" ]; then
    force=1
fi

today=$(date +%F)

# Get the latest entry for today
today_entry=$(grep "^$today " "$CACHE_FILE" | tail -n1)

get_last_seven_entries() {
    header="Date       | USD      | EUR\n--------------------------------"
    today="$(date +%Y-%m-%d)"
    filtered_entries=$(grep -v "^$today" "$CACHE_FILE")
    last_seven=$(echo "$filtered_entries" | tail -n7)
    formatted_entries=$(echo "$last_seven" | awk '{printf "%-10s | %-8s | %s\n", $1, $4, $3}')
    (echo -e "$header"; echo "$formatted_entries") | sed ':a;N;$!ba;s/\n/\\n/g'
}

if [ -n "$today_entry" ] && [ "$force" -eq 0 ]; then
    cache_time=$(echo "$today_entry" | awk '{print $2}')
    cache_eur=$(echo "$today_entry" | awk '{print $3}')
    cache_usd=$(echo "$today_entry" | awk '{print $4}')
    cache_hour=$(echo "$cache_time" | cut -d: -f1)
    cache_min=$(echo "$cache_time" | cut -d: -f2)
    # If cache is after 09:00, use cache
    if [ "$cache_hour" -gt 9 ] || { [ "$cache_hour" -eq 9 ] && [ "$cache_min" -ge 0 ]; }; then
        echo "{\"text\": \"📈 USD: $cache_usd | EUR: $cache_eur\", \"tooltip\": \"$(get_last_seven_entries)\"}"
        exit 0
    fi
fi

usd_response=$(curl -s "$USD_URL")
eur_response=$(curl -s "$EUR_URL")
eur=$(echo "$eur_response" | jq -r '.exchange_middle')
usd=$(echo "$usd_response" | jq -r '.exchange_middle')
now=$(date +%H:%M)

last_entry=$(tail -n1 "$CACHE_FILE")
if [ -n "$last_entry" ]; then
    cache_date=$(echo "$last_entry" | awk '{print $1}')
    cache_eur=$(echo "$last_entry" | awk '{print $3}')
    cache_usd=$(echo "$last_entry" | awk '{print $4}')

    # If api call fails or it's missing data, show the old one and notify user
    if [ -z "$eur" ] || [ -z "$usd" ]; then
        echo "{\"text\": \"📈  <span foreground='#FFA500'> </span>USD: $cache_usd | EUR: $cache_eur\", \"tooltip\": \"$(get_last_seven_entries)\"}"
        notify-send -i "dialog-error" -u critical "Exchange rates" "Failed to fetch exchange rates. Using cached value from $cache_date"
        exit 0
    fi


    if [ "$eur" != "$cache_eur" ] || [ "$usd" != "$cache_usd" ] || [ "$force" -eq 1 ]; then
        icon="dialog-information"
        if (( $(echo "$usd > $cache_usd" | bc -l) )); then
            icon="emblem-default"
        elif (( $(echo "$usd < $cache_usd" | bc -l) )); then
            icon="dialog-error"
        fi
        notify-send -i "$icon" -u critical "Exchange rates" "USD: $cache_usd → $usd\nEUR: $cache_eur → $eur"
    fi
fi

sed -i "/^$(date +%F) /d" "$CACHE_FILE"
echo "$(date +%F) $now $eur $usd" >> "$CACHE_FILE"

echo "{\"text\": \"📈 <span foreground='#00FF00'>  </span>USD: $usd | EUR: $eur\", \"tooltip\": \"$(get_last_seven_entries)\"}"
