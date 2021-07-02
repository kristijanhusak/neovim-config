Neovim and terminal configuration
------

Neovim configuration is completely written in lua, thus it requires Neovim 0.5+.

* Super old tmux setup: [tmux](https://github.com/kristijanhusak/neovim-config/tree/tmux) branch.

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

see [plugins.lua](nvim/lua/partials/plugins.lua#L7)

Font used:
* Current - [IBM Plex Mono](https://github.com/IBM/plex)
* previous fonts
  * [Iosevka](https://github.com/be5invis/Iosevka)
  * [Input mono condensed](http://input.fontbureau.com/)
  * [Inconsolata for powerline](https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/Inconsolata/complete/Inconsolata%20for%20Powerline%20Nerd%20Font%20Complete.otf)

License
-------

This project is licensed under MIT License (see LICENSE file for details). But
each plugin has its own license, so check each one to see what you can do.
