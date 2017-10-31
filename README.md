Neovim and terminal configuration
------

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

* [junegunn/vim-plug](https://github.com/junegunn/vim-plug)
* [christoomey/vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator)
* [w0rp/ale](https://github.com/w0rp/ale)
* [nelstrom/vim-visual-star-search](https://github.com/nelstrom/vim-visual-star-search)
* [Raimondi/delimitMate](https://github.com/Raimondi/delimitMate)
* [mattn/emmet-vim](https://github.com/mattn/emmet-vim)
* [tpope/vim-commentary](https://github.com/tpope/vim-commentary)
* [tpope/vim-surround](https://github.com/tpope/vim-surround)
* [tpope/vim-repeat](https://github.com/tpope/vim-repeat)
* [tpope/vim-fugitive](https://github.com/tpope/vim-fugitive)
* [Xuyuanp/nerdtree-git-plugin](https://github.com/Xuyuanp/nerdtree-git-plugin)
* [scrooloose/nerdtree](https://github.com/scrooloose/nerdtree)
* [airblade/vim-gitgutter](https://github.com/airblade/vim-gitgutter)
* [duff/vim-bufonly](https://github.com/duff/vim-bufonly)
* [gregsexton/MatchTag](https://github.com/gregsexton/MatchTag)
* [sheerun/vim-polyglot](https://github.com/sheerun/vim-polyglot)
* [kristijanhusak/vim-hybrid-material](https://github.com/kristijanhusak/vim-hybrid-material)
* [Shougo/deoplete.nvim](https://github.com/Shougo/deoplete.nvim)
* [Shougo/neosnippet](https://github.com/Shougo/neosnippet)
* [dyng/ctrlsf.vim](https://github.com/dyng/ctrlsf.vim)
* [vimwiki/vimwiki](https://github.com/vimwiki/vimwiki)
* [galooshi/vim-import-js](https://github.com/galooshi/vim-import-js)
* [jreybert/vimagit](https://github.com/jreybert/vimagit)
* [junegunn/fzf](https://github.com/junegunn/fzf)
* [junegunn/fzf.vim](https://github.com/junegunn/fzf.vim)

Font used:
* current - [Iosevka](https://github.com/be5invis/Iosevka)
* previous (and on screenshots) - [Inconsolata for powerline](https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/Inconsolata/complete/Inconsolata%20for%20Powerline%20Nerd%20Font%20Complete.otf)

License
-------

This project is licensed under MIT License (see LICENSE file for details). But
each plugin has its own license, so check each one to see what you can do.
