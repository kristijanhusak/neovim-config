#!/bin/sh
CACHE_FILE="$HOME/.local/share/exchange_rate_cache"
URL="https://api.kursna-lista.info/3c43d44f8badfe38697ea0700c7485c8/kursna_lista"

if [ ! -f "$CACHE_FILE" ]; then
    touch "$CACHE_FILE"
fi

force=0
if [ "$1" = "--force" ]; then
    force=1
fi

# Get the latest entry for today
today=$(date +%F)
today_entry=$(grep "^$today " "$CACHE_FILE" | tail -n1)
if [ -n "$today_entry" ] && [ "$force" -eq 0 ]; then
    cache_time=$(echo "$today_entry" | awk '{print $2}')
    cache_eur=$(echo "$today_entry" | awk '{print $3}')
    cache_usd=$(echo "$today_entry" | awk '{print $4}')
    cache_hour=$(echo "$cache_time" | cut -d: -f1)
    cache_min=$(echo "$cache_time" | cut -d: -f2)
    # If cache is after 09:00, use cache
    if [ "$cache_hour" -gt 9 ] || { [ "$cache_hour" -eq 9 ] && [ "$cache_min" -ge 0 ]; }; then
        echo "📈 USD: $cache_usd | EUR: $cache_eur"
        exit 0
    fi
fi

response=$(curl -s "$URL")
eur=$(echo "$response" | jq -r '.result.eur.sre')
usd=$(echo "$response" | jq -r '.result.usd.sre')
now=$(date +%H:%M)

last_entry=$(tail -n1 "$CACHE_FILE")
if [ -n "$last_entry" ]; then
    cache_eur=$(echo "$last_entry" | awk '{print $3}')
    cache_usd=$(echo "$last_entry" | awk '{print $4}')
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

echo "📈 USD: $usd | EUR: $eur"
