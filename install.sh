#!/usr/bin/env bash
install_oh_my_zsh() {
  echo "Setting up zsh..." \
  && rm -rf ~/.zshrc ~/.oh-my-zsh \
  && ln -s $(pwd)/zshrc ~/.zshrc \
  && git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh \
  && chsh -s /bin/zsh \
  && git clone git://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions \
  && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting \
  && mkdir -p ~/.oh-my-zsh/custom/themes \
  && ln -s $(pwd)/cloud_kris.zsh-theme ~/.oh-my-zsh/custom/themes \
  && rm -rf ~/z.sh \
  && curl -fLo ~/z.sh https://raw.githubusercontent.com/rupa/z/master/z.sh
}

install_neovim() {
  echo "Setting up neovim..." \
  && rm -rf ~/.config/nvim ~/.fzf \
  && git clone https://github.com/kristijanhusak/vim-packager.git ~/.config/nvim/pack/packager/opt/vim-packager \
  && ln -s $(pwd)/snippets ~/.config/nvim/snippets \
  && ln -s $(pwd)/init.vim ~/.config/nvim/init.vim \
  && nvim -c 'call PackagerInit() | call packager#install({ "on_finish": "UpdateRemotePlugins | qa" })'
}

install_ripgrep() {
  echo "Installing ripgrep..." \
  && rm -f /usr/local/bin/rg \
  && curl -L https://github.com/BurntSushi/ripgrep/releases/download/0.10.0/ripgrep-0.10.0-x86_64-unknown-linux-musl.tar.gz | tar zx \
  && cp ripgrep-0.10.0-x86_64-unknown-linux-musl/rg /usr/local/bin \
  && rm -rf ripgrep-0.10.0-x86_64-unknown-linux-musl
}

install_ctags() {
  local ctags_installed=$(which ctags)
  if [[ -z $ctags_installed ]]; then
    echo "Installing universal ctags..." \
    && rm -rf ./ctags \
    && git clone https://github.com/universal-ctags/ctags \
    && cd ctags && ./autogen.sh && ./configure && make && sudo make install && cd ../ && rm -rf ctags
  else
    echo "ctags already installed."
  fi
}

install_diff_so_fancy() {
  local dif_so_fancy_installed=$(which diff-so-fancy)
  if [[ -z $dif_so_fancy_installed ]]; then
    echo "Installing diff-so-fancy..." \
    && npm install -g diff-so-fancy \
    && git config --global core.pager "diff-so-fancy | less --tabs=4 -R"
  else
    echo "diff-so-fancy already installed."
  fi
}

install_manjaro() {
  local yaourt_installed=$(which yaourt)
  if [[ -z $yaourt_installed ]]; then
    echo "Setting up  i3..." \
      && sudo pacman -S yaourt thunar thunar-archive-plugin python-pip gnome-terminal keychain rofi \
      && yaourt -S google-chrome neovim-git nvm zsh-completions \
      && pip install neovim \
      && curl -fLo ~/.i3/focus_win.py https://gist.githubusercontent.com/syl20bnr/6623972/raw/fdd3e1f0fd7efb8e230ec89ca0b5f800ee135412/i3_focus_win.py \
      && pip install i3-py \
      && chmod +x ~/.i3/focus_win.py \
      && echo "NOCONFIRM=1\nBUILD_NOCONFIRM=1\nEDITFILES=0" > ~/.yaourtrc
  else
    echo "Manjaro is already set up."
  fi
}

install_kitty() {
  local kitty_installed=$(which kitty)
  if [[ -z $kitty_installed ]]; then
    echo "Installing kitty..." \
    && rm -rf ~/.local/kitty.app ~/.config/kitty \
    && sudo pacman -S kitty \
    && ln -s $(pwd)/kitty.conf ~/.config/kitty/kitty.conf
  else
    echo "Kitty already installed."
  fi
}

if [[ -z $1 ]]; then
  echo -n "This will delete all your previous nvim, zsh settings. Proceed? (y/n)? "
  read answer
  if echo "$answer" | grep -iq "^y" ;then
    echo "Installing dependencies..." \
    && install_manjaro \
    && install_oh_my_zsh \
    && install_neovim \
    && install_ripgrep \
    && install_ctags \
    && install_diff_so_fancy \
    && install_kitty \
    && echo "Finished installation."
  fi
else
  "install_$1"
fi
