local ret_status="%(?:%{$fg_bold[cyan]%}▶:%{$fg_bold[red]%}▶)"

PROMPT='${ret_status} %{$fg_bold[green]%}%~ %{$fg_bold[cyan]%}$(git_prompt_info)%{$fg_bold[blue]%}%{$reset_color%}'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[green]%}[%{$fg[cyan]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[green]%}]%{$fg[yellow]%} ✗ %{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[green]%}] "
