# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

ZSH_THEME="cloud_kris"

plugins=(git zsh-autosuggestions docker-compose z)

source $ZSH/oh-my-zsh.sh
. ~/z.sh

if [[ -r ~/.phpbrew/bashrc ]]; then
  source ~/.phpbrew/bashrc
fi

alias n='nvim .'
alias install='sudo apt-get install'
alias search='sudo apt-cache search'
alias purge='sudo apt-get purge'
alias update='sudo apt-get purge'
alias c7="sudo chmod -R 777"
alias l="ls -l"
alias c="clear"
alias www="cd /var/www"
alias code="cd ~/code"

export PATH=$PATH:/usr/local/go/bin:~/go/bin
export EDITOR=nvim
export FZF_DEFAULT_COMMAND='rg --files'
# use ctrl+t to toggle autosuggestions(hopefully this wont be needed as
# zsh-autosuggestions is designed to be unobtrusive)
bindkey '^t' autosuggest-execute
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=242'
export THEME='onedark'
source ~/neovim-config/tmux/$THEME.sh

export NVM_DIR="/home/kristijan/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
[ -z "$TMUX" ] && exec tmux

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f ~/.zsh_secret ] && source ~/.zsh_secret

