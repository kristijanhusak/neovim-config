#/bin/sh
rm -rf ~/.config/nvim ~/.tmux.conf ~/.zshrc ~/.oh-my-zsh \
&& sudo apt-get install silversearcher-ag \
&& curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh > dein_installer.sh \
&& sh ./dein_installer.sh ~/.config/nvim/bundle \
&& ln -s $(pwd)/init.vim ~/.config/nvim/init.vim \
&& ln -s $(pwd)/zshrc ~/.zshrc \
&& ln -s $(pwd)/tmux.conf ~/.tmux.conf \
&& ln -s $(pwd)/snippets ~/.config/nvim/snippets \
&& rm ./dein_installer.sh \
&& nvim -c 'call dein#install() | exit' \
&& git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh \
&& chsh -s /bin/zsh \
&& git clone git://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions \
&& mkdir -p ~/.oh-my-zsh/custom/themes \
&& ln -s $(pwd)/cloud_kris.zsh-theme ~/.oh-my-zsh/custom/themes \
&& tic ./xterm-256color-italic.terminfo
