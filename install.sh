#!/usr/bin/env bash
DCONF_PROFILE_BASE_PATH=/org/gnome/terminal/legacy/profiles:
GSETTINGS_PROFILELIST_PATH=org.gnome.Terminal.ProfilesList
profiles=($(gsettings get "$GSETTINGS_PROFILELIST_PATH" list | tr -d "[]\',"))

check_profile_exists() {
  local name=$1
  for idx in "${!profiles[@]}"; do
    if [[ "$(dconf read "$DCONF_PROFILE_BASE_PATH"/:"${profiles[idx]}"/visible-name)" == "'$name'" ]]; then
      printf "%s" "${profiles[idx]}"
      return 0
    fi
  done
}

install_onedark_theme() {
  local existing_profile=$(check_profile_exists "One Dark")
  if [[ -z $existing_profile ]]; then
    echo "Installing onedark gnome terminal theme..." \
    && wget https://raw.githubusercontent.com/denysdovhan/gnome-terminal-one/master/one-dark.sh \
    && chmod +x ./one-dark.sh \
    && ./one-dark.sh \
    && rm -rf ./one-dark.sh
  fi
}

install_nord_theme() {
  local existing_profile=$(check_profile_exists "Nord")
  if [[ -z $existing_profile ]]; then
    echo "Installing nord gnome terminal theme..." \
    && git clone git@github.com:arcticicestudio/nord-gnome-terminal.git \
    && cd $(pwd)/nord-gnome-terminal/src && ./nord.sh && cd ../../ \
    && rm -rf $(pwd)/nord-gnome-terminal
  fi
}

install_on_my_zsh() {
  echo "Setting up zsh..." \
  && rm -rf ~/.zshrc ~/.oh-my-zsh \
  && ln -s $(pwd)/zshrc ~/.zshrc \
  && git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh \
  && chsh -s /bin/zsh \
  && git clone git://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions \
  && mkdir -p ~/.oh-my-zsh/custom/themes \
  && ln -s $(pwd)/cloud_kris.zsh-theme ~/.oh-my-zsh/custom/themes \
  && rm ~/z.sh \
  && curl -fLo ~/z.sh https://raw.githubusercontent.com/rupa/z/master/z.sh
}

setup_tmux() {
  echo "Setting up tmux..." \
  && rm -rf ~/.tmux.conf ~/.tmux \
  && ln -s $(pwd)/tmux.conf ~/.tmux.conf \
  && git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm \
  && ~/.tmux/plugins/tpm/bin/install_plugins
}

install_fzf() {
  echo "Installing fzf..." \
  && rm -rf ~/.fzf \
  && git clone https://github.com/junegunn/fzf ~/.fzf \
  && ~/.fzf/install --all
}

setup_neovim() {
  echo "Setting up neovim..." \
  && rm -rf ~/.config/nvim \
  && git clone https://github.com/k-takata/minpac.git ~/.config/nvim/pack/minpac/opt/minpac \
  && ln -s $(pwd)/snippets ~/.config/nvim/snippets \
  && ln -s $(pwd)/init.vim ~/.config/nvim/init.vim \
  && nvim -c 'packadd minpac | source $MYVIMRC | echo "Installing plugins..." | call minpac#update("", { "do": "UpdateRemotePlugins | qa!"})'
}

install_fonts() {
  echo "Setting up fonts..." \
  && rm -rf ~/.fonts/iosevka-* \
  && cp $(pwd)/fonts/* ~/.fonts/
}

install_ripgrep() {
  echo "Installing ripgrep..." \
  && rm -f /usr/local/bin/rg \
  && curl -L https://github.com/BurntSushi/ripgrep/releases/download/0.8.1/ripgrep-0.8.1-x86_64-unknown-linux-musl.tar.gz | tar zx \
  && cp ripgrep-0.8.1-x86_64-unknown-linux-musl/rg /usr/local/bin \
  && rm -rf ripgrep-0.8.1-x86_64-unknown-linux-musl
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
  && sudo apt-get install urlview xdotool dh-autoreconf dconf-cli \
  && install_onedark_theme \
  && install_nord_theme \
  && install_on_my_zsh \
  && setup_tmux \
  && install_fzf \
  && setup_neovim \
  && install_fonts \
  && install_ripgrep \
  && install_ctags \
  && echo "Finished installation."
fi
