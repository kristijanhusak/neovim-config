#!/usr/bin/env bash

dark_colorscheme='~/.config/kitty/gruvbox.conf'
light_colorscheme='~/.config/kitty/xcodelight.conf'

set_bg () {
  if [[ $1 = 'light' ]]; then
    kitty @ set-colors --all --configured $light_colorscheme
  else
    kitty @ set-colors --all --configured $dark_colorscheme
  fi
  export NVIM_COLORSCHEME_BG=$1
  source ~/.zshrc
}

if [[ $1 = 'toggle' ]]; then
  if [[ $NVIM_COLORSCHEME_BG = 'light' ]]; then
    sed -i 's/light/dark/g' ~/.config/kitty/colors.conf
    sed -i "s@^include.*@include $dark_colorscheme@" ~/.config/kitty/colors.conf
    set_bg 'dark'
  else
    sed -i 's/dark/light/g' ~/.config/kitty/colors.conf
    sed -i "s@^include.*@include $light_colorscheme@" ~/.config/kitty/colors.conf
    set_bg 'light'
  fi
else
  current_bg='dark'

  if [[ -z $(grep -P 'light' ~/.config/kitty/colors.conf) ]]; then
    current_bg='light'
  fi
  set_bg $current_bg
fi


