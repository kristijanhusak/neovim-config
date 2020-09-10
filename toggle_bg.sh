#!/usr/bin/env bash

dark_colorscheme='~/.config/kitty/gruvbox.conf'
light_colorscheme='~/.config/kitty/xcodelight.conf'
local_path=~/.config/kitty/local_color.conf
custom_xresource=~/.Xresources_custom


set_bg () {
  if [[ $1 = 'light' ]]; then
    echo "env NVIM_COLORSCHEME_BG=light\ninclude $light_colorscheme" > $local_path
    kitty @ set-colors --all --configured $light_colorscheme
    echo "" > $custom_xresource
  else
    echo "env NVIM_COLORSCHEME_BG=dark\ninclude $dark_colorscheme" > $local_path
    kitty @ set-colors --all --configured $dark_colorscheme
    echo "*polybar_bg: #FA282828\n*polybar_fg:#ebdbb2" > $custom_xresource
  fi
  export NVIM_COLORSCHEME_BG=$1
  source ~/.zshrc
  if [[ $2 = 'reset_polybar' ]]; then
    xrdb ~/.Xresources
    ~/.config/polybar/start.sh
  fi
}

if [[ $1 = 'toggle' ]]; then
  if [[ $NVIM_COLORSCHEME_BG = 'light' ]]; then
    set_bg 'dark' 'reset_polybar'
  else
    set_bg 'light' 'reset_polybar'
  fi
else
  current_bg='light'

  if [[ -f $local_path && ! -z $(grep 'dark' $local_path) ]]; then
    current_bg='dark'
  fi
  set_bg $current_bg
fi


