# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

ZSH_THEME="lambda-mod"

plugins=(
  git
  zsh-autosuggestions
  docker-compose
  z
  zsh-syntax-highlighting
  history-substring-search
  command-not-found
  copydir
  copyfile
  dircycle
  vi-mode
  jira
)

ENABLE_CORRECTION="true"

source $ZSH/oh-my-zsh.sh
. ~/z.sh

if [[ -r ~/.phpbrew/bashrc ]]; then
  source ~/.phpbrew/bashrc
fi

alias n='nvim .'
alias install='sudo pacman -S'
alias search='sudo pacman -Ss'
alias remove='sudo pacman -R'
alias update='sudo pacman -Sy'
alias yinstall='yaourt -S'
alias ysearch='yaourt -Ss'
alias yremove='yaourt -R'
alias yupdate='yaourt -Sy'
alias c7="sudo chmod -R 777"
alias l="ls -l"
alias c="clear"
alias www="cd /var/www"
alias weather="curl http://wttr.in/Novi sad"
alias gs="git status"
alias code="cd ~/code"
alias lg="lazygit"

export PATH=$PATH:/usr/local/go/bin:~/go/bin:~/.local/bin
export LESS=R
export EDITOR=nvim
export MANPAGER="nvim -c 'set ft=man' -"
export FZF_DEFAULT_COMMAND='rg --files'
export LESS=R
export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND="fg=magenta,bold,underline"
setopt HIST_IGNORE_ALL_DUPS

# use ctrl+t to toggle autosuggestions(hopefully this wont be needed as
# zsh-autosuggestions is designed to be unobtrusive)
export KEYTIMEOUT=1

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=242'
[ -f ~/.zsh_secret ] && source ~/.zsh_secret

export NVM_DIR="/home/kristijan/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

eval $(keychain --eval --quiet ~/.ssh/id_rsa)
