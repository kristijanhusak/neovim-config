#/bin/sh
echo -n "This will delete all your previous nvim, tmux and zsh settings. Proceed? (y/n)? "
read answer
if echo "$answer" | grep -iq "^y" ;then
    echo "Installing dependencies..." \
    && sudo apt-get install urlview xdotool dh-autoreconf dconf-cli \
    && echo "Installing nord gnome terminal theme..." \
    && git clone git@github.com:arcticicestudio/nord-gnome-terminal.git \
    && cd $(pwd)/nord-gnome-terminal/src && ./nord.sh && cd ../../ \
    && rm -rf $(pwd)/nord-gnome-terminal \
    && echo "Setting up zsh..." \
    && rm -rf ~/.zshrc ~/.oh-my-zsh \
    && ln -s $(pwd)/zshrc ~/.zshrc \
    && git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh \
    && chsh -s /bin/zsh \
    && git clone git://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions \
    && mkdir -p ~/.oh-my-zsh/custom/themes \
    && ln -s $(pwd)/cloud_kris.zsh-theme ~/.oh-my-zsh/custom/themes \
    && echo "Setting up tmux..." \
    && rm -rf ~/.tmux.conf ~/.tmux \
    && ln -s $(pwd)/tmux.conf ~/.tmux.conf \
    && git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm \
    && ~/.tmux/plugins/tpm/bin/install_plugins \
    && echo "Setting up neovim..." \
    && rm -rf ~/.config/nvim \
    && curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
    && ln -s $(pwd)/snippets ~/.config/nvim/snippets \
    && ln -s $(pwd)/init.vim ~/.config/nvim/init.vim \
    && nvim -c 'PlugInstall' -c 'qa!' \
    && echo "Setting up fonts..." \
    && rm -rf ~/.fonts/iosevka-* \
    && cp $(pwd)/fonts/* ~/.fonts/ \
    && echo "Installing ripgrep..." \
    && rm /usr/local/bin/rg \
    && curl -L https://github.com/BurntSushi/ripgrep/releases/download/0.8.1/ripgrep-0.8.1-x86_64-unknown-linux-musl.tar.gz | tar zx \
    && cp ripgrep-0.8.1-x86_64-unknown-linux-musl/rg /usr/local/bin \
    && rm -rf ripgrep-0.8.1-x86_64-unknown-linux-musl \
    && echo "Installing z.sh..." \
    && rm ~/z.sh \
    && curl -fLo ~/z.sh https://raw.githubusercontent.com/rupa/z/master/z.sh \
    && echo "Installing universal ctags..." \
    && git clone https://github.com/universal-ctags/ctags \
    && cd ctags && ./autogen.sh && ./configure && make && sudo make install && cd ../ && rm -rf ctags \
    && echo "Installing diff-so-fancy..." \
    && npm install -g diff-so-fancy \
    && git config --global core.pager "diff-so-fancy | less --tabs=4 -R" \
    && echo "Installing slack notifier..." \
    && rm -f /usr/local/bin/slack-notifier \
    && ln -s $(pwd)/bin/slack-notifier /usr/local/bin/slack-notifier \
    && tic ./xterm-256color-italic.terminfo \
    && echo "Finished installation."
fi
