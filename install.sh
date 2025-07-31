#!/usr/bin/env bash

install_oh_my_zsh() {
  echo "Setting up zsh..." \
  && rm -rf ~/.zshrc \
  && ln -s $(pwd)/zsh/zshrc ~/.zshrc \
  && git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions \
  && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting \
  && git clone https://github.com/Aloxaf/fzf-tab ~/.oh-my-zsh/custom/plugins/fzf-tab \
  && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k \
  && ln -s $(pwd)/zsh/themes/* ~/.oh-my-zsh/custom/themes \
  && rm -rf ~/z.sh \
  && curl -fLo ~/z.sh https://raw.githubusercontent.com/rupa/z/master/z.sh
}

install_neovim() {
  echo "Setting up neovim..." \
  && rm -rf ~/.config/nvim ~/.fzf \
  && ln -s $(pwd)/nvim ~/.config/nvim \
  && yay -S ripgrep
}

install_emacs() {
  echo "Setting up emacs..." \
  && mkdir -p ~/.config/emacs \
  && rm -rf ~/.config/emacs/init.el \
  && ln -s $(pwd)/emacs/init.el ~/.config/emacs
}

install_packages() {
  ehco"Installing packages..." \
    && yay -S keychain go dropbox dropbox-cli meld cronie jq
}

install_diff_so_fancy() {
  echo "Installing diff-so-fancy..." \
    && npm install -g diff-so-fancy \
    && git config --global core.pager "diff-so-fancy | less --tabs=4 -R"
}

install_kitty() {
  echo "Installing kitty..." \
    && rm -rf ~/.local/kitty.app ~/.config/kitty \
    && yay -S kitty \
    && ln -s $(pwd)/kitty ~/.config/kitty
}

install_i3() {
  rm -rf ~/.config/i3 \
    && yay -S rofi polybar ttf-twemoji ttf-nerd-fonts-symbols-mono ttf-jetbrains-mono \
    && ln -s $(pwd)/i3 ~/.config/i3
}

install_sway() {
  yay -S sway swaybg swaylock swaync swayidle xorg-wayland waybar grim slurp wl-clipboard rofi \
  && rm -rf ~/.config/sway ~/.config/waybar \
    && ln -s $(pwd)/sway ~/.config/sway \
    && ln -s $(pwd)/waybar ~/.config/waybar \
}

install_hyprland() {
  yay -S cmake meson cpio pkg-config g++ gcc zenity hyprlock swaync swaybg hypridle xorg-wayland waybar grim slurp wl-clipboard rofi-wayland hyprland wf-recorder \
  && rm -rf ~/.config/hypr ~/.config/waybar \
    && ln -s $(pwd)/hypr ~/.config/hypr \
    && ln -s $(pwd)/waybar ~/.config/waybar \
    && hyprpm update \
    && hyprpm add https://github.com/outfoxxed/hy3 \
}

install_rofi() {
  yay -S rofi \
    && rm -rf ~/.config/rofi \
    && ln -s $(pwd)/rofi ~/.config/rofi
}

install_mutt() {
  yay -S neomutt mutt-wizard cyrus-sasl-xoauth2-git abook lynx
}

if [[ -z $1 ]]; then
  echo "Provide argument"
  exit 1
else
  "install_$1" $1
fi
