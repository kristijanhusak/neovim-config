# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="cloud_kris"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git laravel4 composer symfony2 zshmarks)

source $ZSH/oh-my-zsh.sh

# Customize to your needs...
export PATH=$PATH:/usr/lib/lightdm/lightdm:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/home/kristijan/bin:/usr/local/java/jdk1.7.0_45/bin:vendor/bin:/home/kristijan/android-sdk/platform-tools:/home/kristijan/android-sdk/tools:/home/kristijan/.composer/vendor/bin

NODE_PATH='/usr/local/lib/jsctags:${NODE_PATH}'

alias c7='sudo chmod -R 777'
alias rma='sudo rm -rf'
alias cw='compass watch'
alias gw='grunt watch'
alias install='sudo apt-get install'
alias search='sudo apt-cache search'
alias purge='sudo apt-get purge'
alias dl='cd ~/Downloads'
alias c7="sudo chmod -R 777"
alias r7="sudo rm -rf"
alias l="ls -l"
alias c="clear"
alias cp="cp -r"
alias t="phpunit"
alias npm-exec='PATH=$(npm bin):$PATH'
alias www="cd /var/www"
alias code="cd ~/code"
alias vup="vagrant up"
alias vssh="vagrant ssh"
alias stv="vboxmanage list runningvms | sed -r 's/.*\{(.*)\}/\1/' | xargs -L1 -I {} VBoxManage controlvm {} savestate && sudo shutdown -h now"
alias str="vboxmanage list runningvms | sed -r 's/.*\{(.*)\}/\1/' | xargs -L1 -I {} VBoxManage controlvm {} savestate && sudo shutdown -r now"

#setup zsh-autosuggestions
source ~/.zsh-autosuggestions/zsh-autosuggestions.zsh

# use ctrl+t to toggle autosuggestions(hopefully this wont be needed as
# zsh-autosuggestions is designed to be unobtrusive)
bindkey '^T' autosuggest-toggle
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=6'

export NVM_DIR="/home/kristijan/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
[[ $TERM != "screen-256color" ]] && exec tmux -2
