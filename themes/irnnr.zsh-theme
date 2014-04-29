
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[white]%}[ %{$fg[red]%}± on ⭠ "
ZSH_THEME_GIT_PROMPT_SUFFIX=" %{$fg_bold[white]%}]%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg_bold[green]%}✓%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg[cyan]%}▴%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_BEHIND="%{$fg[magenta]%}▾%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_STAGED="%{$fg_bold[green]%}●%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNSTAGED="%{$fg_bold[yellow]%}●%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg_bold[red]%}●%{$reset_color%}"

bureau_git_branch () {
  ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
  ref=$(command git rev-parse --short HEAD 2> /dev/null) || return
  echo "${ref#refs/heads/}"
}

bureau_git_status () {
  _STATUS=""
  if [[ $(command git status --short 2> /dev/null) != "" ]]; then
    _INDEX=$(command git status --porcelain -b 2> /dev/null)
    if $(echo "$_INDEX" | grep '^[AMRD]. ' &> /dev/null); then
      _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_STAGED"
    fi
    if $(echo "$_INDEX" | grep '^.[MTD] ' &> /dev/null); then
      _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_UNSTAGED"
    fi
    if $(echo "$_INDEX" | grep -E '^\?\? ' &> /dev/null); then
      _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_UNTRACKED"
    fi
    if $(echo "$_INDEX" | grep '^UU ' &> /dev/null); then
      _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_UNMERGED"
    fi
    if $(command git rev-parse --verify refs/stash >/dev/null 2>&1); then
      _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_STASHED"
    fi
    if $(echo "$_INDEX" | grep '^## .*ahead' &> /dev/null); then
      _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_AHEAD"
    fi
    if $(echo "$_INDEX" | grep '^## .*behind' &> /dev/null); then
      _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_BEHIND"
    fi
    if $(echo "$_INDEX" | grep '^## .*diverged' &> /dev/null); then
      _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_DIVERGED"
    fi
  else
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_CLEAN"
  fi

  echo $_STATUS
}

bureau_git_prompt () {
  local _branch=$(bureau_git_branch)
  local _status=$(bureau_git_status)
  local _result=""
  if [[ "${_branch}x" != "x" ]]; then
    _result="$ZSH_THEME_GIT_PROMPT_PREFIX$_branch %{$fg_bold[white]%}|"
    if [[ "${_status}x" != "x" ]]; then
      _result="$_result $_status"
    fi
    _result="$_result$ZSH_THEME_GIT_PROMPT_SUFFIX"
  fi
  echo $_result
}

local ret_status="%(?:%{$fg_bold[green]%}⚡ :%{$fg_bold[red]%}⚡ %s)"
PROMPT='${ret_status}%{$fg_bold[green]%}%p %{$fg[blue]%}${PWD/#$HOME/~}$(bureau_git_prompt) % %{$reset_color%}» '
