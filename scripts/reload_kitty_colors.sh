#!/usr/bin/env bash

set -eu

COLOR_FILE="${1:-$HOME/.cache/main_colorscheme.conf}"

if [ ! -f "$COLOR_FILE" ]; then
  echo "Kitty colors file not found: $COLOR_FILE" >&2
  exit 1
fi

if ! command -v pgrep >/dev/null 2>&1; then
  echo "pgrep is required to reload Kitty colors" >&2
  exit 1
fi

pgrep -x kitty | while IFS= read -r pid; do
  [ -n "$pid" ] && kill -USR1 "$pid"
done
