Neovim and terminal configuration
------

**NOTE**: I recently switched to [Manjaro i3](https://manjaro.github.io/homepage/public/download/i3/)
which removed my necessity for tmux. If you want to see my old setup with tmux, checkout [tmux](https://github.com/kristijanhusak/neovim-config/tree/tmux) branch.

This is my Neovim editor setup, with zsh and i3 configurations.
Feel free to fork it
and submit a pull request if you found any bug.

**Warning**: Install script removes all previous configuration (zshrc, oh-my-zsh, nvim, i3)

Installation
-----------

    $ git clone https://github.com/kristijanhusak/neovim-config.git ~/neovim-config
    $ cd ~/neovim-config
    $ chmod +x ./install.sh
    $ ./install.sh
    $ nvim

Plugins
----------------

* [kristijanhusak/vim-packager](https://github.com/kristijanhusak/vim-packager)
* [kristijanhusak/vim-js-file-import](https://github.com/kristijanhusak/vim-js-file-import)
* [kristijanhusak/defx-git](https://github.com/kristijanhusak/defx-git)
* [kristijanhusak/defx-icons](https://github.com/kristijanhusak/defx-icons)
* [kristijanhusak/vim-create-pr](https://github.com/kristijanhusak/vim-create-pr)
* [mgedmin/python-imports.vim](https://github.com/mgedmin/python-imports.vim)
* [phpactor/phpactor](https://github.com/phpactor/phpactor)
* [Shougo/defx.nvim](https://github.com/Shougo/defx.nvim)
* [Raimondi/delimitMate](https://github.com/Raimondi/delimitMate)
* [manasthakur/vim-commentor](https://github.com/manasthakur/vim-commentor)
* [tpope/vim-surround](https://github.com/tpope/vim-surround)
* [tpope/vim-repeat](https://github.com/tpope/vim-repeat)
* [tpope/vim-fugitive](https://github.com/tpope/vim-fugitive)
* [tpope/vim-sleuth](https://github.com/tpope/vim-sleuth)
* [lambdalisue/vim-backslash](https://github.com/lambdalisue/vim-backslash)
* [AndrewRadev/splitjoin.vim](https://github.com/AndrewRadev/splitjoin.vim)
* [airblade/vim-gitgutter](https://github.com/airblade/vim-gitgutter)
* [sheerun/vim-polyglot](https://github.com/sheerun/vim-polyglot)
* [junegunn/fzf](https://github.com/junegunn/fzf)
* [junegunn/fzf.vim](https://github.com/junegunn/fzf.vim)
* [ludovicchabant/vim-gutentags](https://github.com/ludovicchabant/vim-gutentags)
* [vimwiki/vimwiki](https://github.com/vimwiki/vimwiki)
* [editorconfig/editorconfig-vim](https://github.com/editorconfig/editorconfig-vim)
* [andymass/vim-matchup](https://github.com/andymass/vim-matchup)
* [haya14busa/vim-asterisk](https://github.com/haya14busa/vim-asterisk)
* [osyo-manga/vim-anzu](https://github.com/osyo-manga/vim-anzu)
* [dyng/ctrlsf.vim](https://github.com/dyng/ctrlsf.vim)
* [neoclide/coc.nvim](https://github.com/neoclide/coc.nvim)
* [w0rp/ale](https://github.com/w0rp/ale)
* [itchyny/lightline.vim](https://github.com/itchyny/lightline.vim)
* [honza/vim-snippets](https://github.com/honza/vim-snippets)
* [AndrewRadev/tagalong.vim](https://github.com/AndrewRadev/tagalong.vim)
* [sodapopcan/vim-twiggy](https://github.com/sodapopcan/vim-twiggy)
* [gruvbox-community/gruvbox](https://github.com/gruvbox-community/gruvbox)

Font used:
* Current - [Iosevka](https://github.com/be5invis/Iosevka)
* previous fonts
  * [Input mono condensed](http://input.fontbureau.com/)
  * [Inconsolata for powerline](https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/Inconsolata/complete/Inconsolata%20for%20Powerline%20Nerd%20Font%20Complete.otf)

License
-------

This project is licensed under MIT License (see LICENSE file for details). But
each plugin has its own license, so check each one to see what you can do.
