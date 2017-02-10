
========
This is my Neovim editor setup, with zsh and tmux configurations.
Feel free to fork it
and submit a pull request if you found any bug.

**Warning**: Install script removes all previous configuration (zshrc, oh-my-zsh, nvim, tmux)

Installation
-----------

    $ git clone https://github.com/kristijanhusak/neovim-config.git ~/neovim-config
    $ cd ~/neovim-config
    $ chmod +x ./install.sh
    $ ./install.sh
    $ nvim
    $ :UpdateRemotePlugins

Plugins
----------------

* [Shougo/dein.vim](http://github.com/Shougo/dein.vim)
* [christoomey/vim-tmux-navigator](http://github.com/christoomey/vim-tmux-navigator)
* [ryanoasis/vim-devicons](http://github.com/ryanoasis/vim-devicons)
* [w0rp/ale](http://github.com/w0rp/ale)
* [nelstrom/vim-visual-star-search](http://github.com/nelstrom/vim-visual-star-search)
* [mileszs/ack.vim](http://github.com/mileszs/ack.vim)
* [Raimondi/delimitMate](http://github.com/Raimondi/delimitMate)
* [mattn/emmet-vim](http://github.com/mattn/emmet-vim)
* [tpope/vim-commentary](http://github.com/tpope/vim-commentary)
* [tpope/vim-surround](http://github.com/tpope/vim-surround)
* [tpope/vim-repeat](http://github.com/tpope/vim-repeat)
* [tpope/vim-fugitive](http://github.com/tpope/vim-fugitive)
* [scrooloose/nerdtree](http://github.com/scrooloose/nerdtree)
* [airblade/vim-gitgutter](http://github.com/airblade/vim-gitgutter)
* [vim-airline/vim-airline](http://github.com/vim-airline/vim-airline)
* [vim-airline/vim-airline-themes](http://github.com/vim-airline/vim-airline-themes)
* [duff/vim-bufonly](http://github.com/duff/vim-bufonly)
* [gregsexton/MatchTag](http://github.com/gregsexton/MatchTag)
* [sheerun/vim-polyglot](http://github.com/sheerun/vim-polyglot)
* [kristijanhusak/vim-hybrid-material](http://github.com/kristijanhusak/vim-hybrid-material)
* [Shougo/deoplete.nvim](http://github.com/Shougo/deoplete.nvim)
* [Shougo/neosnippet](http://github.com/Shougo/neosnippet)
* [honza/vim-snippets](http://github.com/honza/vim-snippets)
* [dkprice/vim-easygrep](http://github.com/dkprice/vim-easygrep)
* [ctrlpvim/ctrlp.vim](http://github.com/ctrlpvim/ctrlp.vim)

Font used:
[Inconsolata for powerline](https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/Inconsolata/complete/Inconsolata%20for%20Powerline%20Nerd%20Font%20Complete.otf)

License
-------

This project is licensed under MIT License (see LICENSE file for details). But
each plugin has its own license, so check each one to see what you can do.
