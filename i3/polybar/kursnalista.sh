#!/bin/sh
URL="https://api.kursna-lista.info/3c43d44f8badfe38697ea0700c7485c8/kursna_lista"

response=$(curl -s "$URL")

eur=$(echo "$response" | jq -r '.result.eur.sre')
usd=$(echo "$response" | jq -r '.result.usd.sre')

echo "📈 USD: $usd | EUR: $eur"
