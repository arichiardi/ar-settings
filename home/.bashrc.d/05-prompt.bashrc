#
# This is using bash-git-prompt from brew
#
if `if_os darwin`; then
  if [ -f "/opt/homebrew/opt/bash-git-prompt/share/gitprompt.sh" ]; then
    __GIT_PROMPT_DIR="/opt/homebrew/opt/bash-git-prompt/share"
    GIT_PROMPT_ONLY_IN_REPO=1
    source "/opt/homebrew/opt/bash-git-prompt/share/gitprompt.sh"
  fi
fi

#
# This is using the built-in git contrib completion
#
if `if_os linux`; then
  source "/usr/share/git/completion/git-prompt.sh"

  GIT_PS1_SHOWUPSTREAM=verbose
  GIT_PS1_SHOWUNTRACKEDFILES=1
  GIT_PS1_SHOWSTASHSTATE=1
  GIT_PS1_SHOWDIRTYSTATE=1
  GIT_PS1_DESCRIBE_STYLE="describe"

  if ${use_color} ; then
    GIT_PS1_SHOWCOLORHINTS=1
  fi

  NC="\[\e[0m\]"
  BOLD="\[\e[1m\]"
  BLUE="\[\e[34m\]"

  CC_EXCLUDED="0,7,15,17"
  PS1_COLORED_AT='@'
  PS1_COLORED_HOST='\h'

  if [[ "$use_color" == "true" ]] && [[ -n "$SSH_CLIENT" || -n "$SSH_TTY" ]]; then
    PS1_COLORED_HOST=$(context-color --prompt --background --exclude $CC_EXCLUDED --context "hostname")\\h${NC}
  else
    PS1_COLORED_AT=$(context-color --prompt --exclude $CC_EXCLUDED)@${NC}
  fi

  PROMPT_COMMAND=
  if ${use_color} ; then
    GIT_PS1_SHOWCOLORHINTS=1
    PROMPT_COMMAND='__git_ps1 "${debian_chroot:+($debian_chroot)}${BOLD}\u${PS1_COLORED_AT}${PS1_COLORED_HOST} ${BLUE}\w${NC}" "\\$ "'
  else
    PROMPT_COMMAND='__git_ps1 "${debian_chroot:+($debian_chroot)}\u@\h \w" "\\$ "'
  fi
fi
