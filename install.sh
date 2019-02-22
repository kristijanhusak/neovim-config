#!/usr/bin/env bash
install_oh_my_zsh() {
  echo "Setting up zsh..." \
  && rm -rf ~/.zshrc ~/.oh-my-zsh \
  && ln -s $(pwd)/zsh/zshrc ~/.zshrc \
  && git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh \
  && chsh -s /bin/zsh \
  && git clone git://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions \
  && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting \
  && ln -s $(pwd)/zsh/themes/* ~/.oh-my-zsh/custom/themes \
  && rm -rf ~/z.sh \
  && curl -fLo ~/z.sh https://raw.githubusercontent.com/rupa/z/master/z.sh
}

install_neovim() {
  echo "Setting up neovim..." \
  && rm -rf ~/.config/nvim ~/.fzf \
  && ln -s $(pwd)/nvim ~/.config/nvim \
  && git clone https://github.com/kristijanhusak/vim-packager.git ~/.config/nvim/pack/packager/opt/vim-packager \
  && nvim -c 'PackagerInstall'
}

install_ripgrep() {
  echo "Installing ripgrep..." \
  && rm -f /usr/local/bin/rg \
  && curl -L https://github.com/BurntSushi/ripgrep/releases/download/0.10.0/ripgrep-0.10.0-x86_64-unknown-linux-musl.tar.gz | tar zx \
  && cp ripgrep-0.10.0-x86_64-unknown-linux-musl/rg /usr/local/bin \
  && rm -rf ripgrep-0.10.0-x86_64-unknown-linux-musl
}

install_ctags() {
  echo "Installing universal ctags..." \
    && rm -rf ./ctags \
    && git clone https://github.com/universal-ctags/ctags \
    && cd ctags && ./autogen.sh && ./configure && make && sudo make install && cd ../ && rm -rf ctags
}

install_diff_so_fancy() {
  echo "Installing diff-so-fancy..." \
    && npm install -g diff-so-fancy \
    && git config --global core.pager "diff-so-fancy | less --tabs=4 -R"
}

install_kitty() {
  echo "Installing kitty..." \
    && rm -rf ~/.local/kitty.app ~/.config/kitty \
    && sudo pacman -S kitty \
    && ln -s $(pwd)/kitty ~/.config/kitty
}

install_i3() {
  rm -rf ~/.i3 \
    && yaourt -S i3blocks-git kbdd-git \
    && sudo pacman -S sysstat yad \
    && ln -s $(pwd)/i3 ~/.i3
}

if [[ -z $1 ]]; then
  echo -n "This will delete all your previous nvim, zsh settings. Proceed? (y/n)? "
  read answer
  if echo "$answer" | grep -iq "^y" ;then
    echo "Installing dependencies..." \
    && install_i3 \
    && install_oh_my_zsh \
    && install_neovim \
    && install_ripgrep \
    && install_ctags \
    && install_diff_so_fancy \
    && install_kitty \
    && echo "Finished installation."
  fi
else
  "install_$1" $1
fi
