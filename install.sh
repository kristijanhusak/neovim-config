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
  && curl -fLo ~/z.sh https://raw.githubusercontent.com/rupa/z/master/z.sh \
  && tic xterm-256color-italic.terminfo
}

setup_tmux() {
  echo "Setting up tmux..." \
  && rm -rf ~/.tmux.conf ~/.tmux \
  && ln -s $(pwd)/tmux.conf ~/.tmux.conf \
  && git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm \
  && ~/.tmux/plugins/tpm/bin/install_plugins
}

setup_neovim() {
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
  && curl -L https://github.com/BurntSushi/ripgrep/releases/download/0.9.0/ripgrep-0.9.0-x86_64-unknown-linux-musl.tar.gz | tar zx \
  && cp ripgrep-0.9.0-x86_64-unknown-linux-musl/rg /usr/local/bin \
  && rm -rf ripgrep-0.9.0-x86_64-unknown-linux-musl
}

install_ctags() {
  local ctags_installed=$(which ctags)
  if [[ -z $ctags_installed ]]; then
    echo "Installing universal ctags..." \
    && rm -rf ./ctags \
    && git clone https://github.com/universal-ctags/ctags \
    && cd ctags && ./autogen.sh && ./configure && make && sudo make install && cd ../ && rm -rf ctags
  fi
}

install_diff_so_fancy() {
  local dif_so_fancy_installed=$(which diff-so-fancy)
  if [[ -z $dif_so_fancy_installed ]]; then
    echo "Installing diff-so-fancy..." \
    && npm install -g diff-so-fancy \
    && git config --global core.pager "diff-so-fancy | less --tabs=4 -R"
  fi
}

echo -n "This will delete all your previous nvim, tmux and zsh settings. Proceed? (y/n)? "
read answer
if echo "$answer" | grep -iq "^y" ;then
  echo "Installing dependencies..." \
  && sudo apt-get install urlview xdotool dh-autoreconf dconf-cli xsel \
  && install_oh_my_zsh \
  && setup_tmux \
  && setup_neovim \
  && install_ripgrep \
  && install_ctags \
  && install_diff_so_fancy \
  && echo "Finished installation."
fi
