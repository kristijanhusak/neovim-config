#/bin/sh
echo -n "This will delete all your previous nvim, tmux, zsh and iosevka fonts. Proceed? (y/n)? "
read answer
if echo "$answer" | grep -iq "^y" ;then
    rm -rf ~/.config/nvim ~/.tmux.conf ~/.tmux ~/.zshrc ~/.oh-my-zsh ~/.fonts/iosevka* /usr/local/bin/slack-notifier \
    && cp $(pwd)/fonts/* ~/.fonts/ \
    && curl -L https://github.com/BurntSushi/ripgrep/releases/download/0.7.1/ripgrep-0.7.1-x86_64-unknown-linux-musl.tar.gz | tar zx \
    && cp ripgrep-0.7.1-x86_64-unknown-linux-musl/rg /usr/local/bin \
    && rm -rf ripgrep-0.7.1-x86_64-unknown-linux-musl \
    && curl -fLo ~/z.sh https://raw.githubusercontent.com/rupa/z/master/z.sh \
    && curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
    && ln -s $(pwd)/init.vim ~/.config/nvim/init.vim \
    && ln -s $(pwd)/zshrc ~/.zshrc \
    && ln -s $(pwd)/tmux.conf ~/.tmux.conf \
    && ln -s $(pwd)/snippets ~/.config/nvim/snippets \
    && nvim -c 'PlugInstall' -c 'qa!' \
    && sudo apt-get install dh-autoreconf \
    && git clone https://github.com/universal-ctags/ctags \
    && cd ctags && ./autogen.sh && ./configure && make && sudo make install && cd ../ && rm -rf ctags \
    && npm install -g diff-so-fancy \
    && git config --global core.pager "diff-so-fancy | less --tabs=4 -R" \
    && git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh \
    && git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm \
    && ~/.tmux/plugins/tpm/bin/install_plugins \
    && chsh -s /bin/zsh \
    && git clone git://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions \
    && mkdir -p ~/.oh-my-zsh/custom/themes \
    && ln -s $(pwd)/cloud_kris.zsh-theme ~/.oh-my-zsh/custom/themes \
    && ln -s $(pwd)/bin/slack-notifier /usr/local/bin/slack-notifier \
    && tic ./xterm-256color-italic.terminfo
fi
