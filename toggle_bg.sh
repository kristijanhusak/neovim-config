#!/usr/bin/env bash

set_bg () {
  local base_color_path=~/.config/nvim/pack/packager/start/cosmic_latte/terminals/kitty
  kitty @ set-colors --all --configured "$base_color_path/cosmic_latte_$1.conf"
  export NVIM_COLORSCHEME_BG=$1
}

current_bg='light'

if [[ -z $(grep -P 'light' ~/.config/kitty/colors.conf) ]]; then
  current_bg='dark'
fi

if [[ $1 = 'toggle' ]]; then
  if [[ $NVIM_COLORSCHEME_BG = 'light' ]]; then
    sed -i 's/light/dark/g' ~/.config/kitty/colors.conf
    set_bg 'dark'
  else
    sed -i 's/dark/light/g' ~/.config/kitty/colors.conf
    set_bg 'light'
  fi
else
  set_bg $current_bg
fi


