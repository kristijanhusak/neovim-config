#/bin/sh
rm -rf ~/.config/nvim ~/.tmux.conf ~/.zshrc ~/.oh-my-zsh \
&& sudo apt-get install silversearcher-ag \
&& curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
&& ln -s $(pwd)/init.vim ~/.config/nvim/init.vim \
&& ln -s $(pwd)/zshrc ~/.zshrc \
&& ln -s $(pwd)/tmux.conf ~/.tmux.conf \
&& ln -s $(pwd)/snippets ~/.config/nvim/snippets \
&& nvim -c 'PlugInstall' -c 'qa!' \
&& sudo apt-get install dh-autoreconf \
&& git clone https://github.com/universal-ctags/ctags \
&& cd ctags && ./autogen.sh && ./configure && make && sudo make install && cd ../ && rm -rf ctags \
&& git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh \
&& chsh -s /bin/zsh \
&& git clone git://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions \
&& mkdir -p ~/.oh-my-zsh/custom/themes \
&& ln -s $(pwd)/cloud_kris.zsh-theme ~/.oh-my-zsh/custom/themes \
&& tic ./xterm-256color-italic.terminfo
