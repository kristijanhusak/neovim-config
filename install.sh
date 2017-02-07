#/bin/sh
rm -rf ~/.config/nvim ~/.ackrc ~/.tmux.conf ~/.zshrc \
&& curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh > dein_installer.sh \
&& sh ./dein_installer.sh ~/.config/nvim/bundle \
&& ln -s $(pwd)/init.vim ~/.config/nvim/init.vim \
&& ln -s $(pwd)/ackrc ~/.ackrc \
&& ln -s $(pwd)/zshrc ~/.zshrc \
&& ln -s $(pwd)/tmux.conf ~/.tmux.conf \
&& ln -s $(pwd)/snippets ~/.config/nvim/snippets \
&& rm ./dein_installer.sh \
&& sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)" \
&& git clone git://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
