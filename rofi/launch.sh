colorscheme=$(grep -o -P '(?<=NVIM_COLORSCHEME_BG=).*' ~/.cache/main_colorscheme.conf)

rofi -combi-modi window,run -show combi -modi combi -theme ~/.config/rofi/spotlight-$colorscheme.rasi
