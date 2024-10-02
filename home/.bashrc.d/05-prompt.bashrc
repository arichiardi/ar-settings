export GIT_PS1_SHOWCONFLICTSTATE=yes

if `is_os linux`; then
    source "/usr/share/git/completion/git-prompt.sh"
elif `is_os darwin`; then
    export GIT_PS1_SHOWDIRTYSTATE=0 # git is very slow on MacOS
    source "/opt/git/contrib/completion/git-prompt.sh"
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

GIT_PS1_SHOWUPSTREAM=verbose
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWSTASHSTATE=1
GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_DESCRIBE_STYLE="describe"

if ${use_color} ; then
    GIT_PS1_SHOWCOLORHINTS=1
fi

PROMPT_COMMAND=
if ${use_color} ; then
    GIT_PS1_SHOWCOLORHINTS=1
    PROMPT_COMMAND='__git_ps1 "${BOLD}\u${PS1_COLORED_AT}${PS1_COLORED_HOST} ${BLUE}\w${NC}" "\\$ "'
else
    PROMPT_COMMAND='__git_ps1 "\u@\h \w" "\\$ "'
fi
