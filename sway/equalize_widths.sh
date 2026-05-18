#!/bin/sh

workspace=$(
  swaymsg -r -t get_workspaces | jq -r '.[] | select(.focused == true) | .name' | head -n 1
) || exit 1

[ -n "$workspace" ] || exit 1

balance_once() {
  tree=$(swaymsg -r -t get_tree) || return 1

  groups=$(
    printf '%s\n' "$tree" | jq -r --arg workspace "$workspace" '
      first(.. | objects | select(.type? == "workspace" and .name == $workspace))
      | recurse(.nodes[]?)
      | select(.layout == "splith" and ((.nodes // []) | length) > 1)
      | [.nodes[].id | tostring]
      | join(" ")
    '
  )

  printf '%s\n' "$groups" | while IFS= read -r group; do
    [ -n "$group" ] || continue

    set -- $group
    count=$#

    [ "$count" -ge 2 ] || continue

    base_width=$((100 / count))
    remainder=$((100 % count))

    for id in "$@"; do
      width=$base_width
      if [ "$remainder" -gt 0 ]; then
        width=$((width + 1))
        remainder=$((remainder - 1))
      fi

      swaymsg -q "[con_id=$id] resize set width $width ppt" >/dev/null
    done
  done
}

for _ in 1 2 3 4; do
  balance_once || exit 1
done
