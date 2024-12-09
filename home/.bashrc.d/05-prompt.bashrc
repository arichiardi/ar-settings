if `is_os linux`; then
    source "/usr/share/git/completion/git-prompt.sh"
elif `is_os darwin`; then
    export GIT_PS1_SHOWDIRTYSTATE=0 # git is very slow on MacOS
    source "/opt/git/contrib/completion/git-prompt.sh"
fi

export NC="\[\e[0m\]"
export BOLD="\[\e[1m\]"
export BLUE="\[\e[34m\]"

export PS1_COLORED_AT='@'
export PS1_COLORED_HOST='\h'

export GIT_PS1_SHOWCONFLICTSTATE=yes
export GIT_PS1_SHOWUPSTREAM=verbose
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWSTASHSTATE=1
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_DESCRIBE_STYLE="describe"

export AR_PROMPT_COLOR_SUPPORTED=$(detect_color_support)

function __do_ps1 () {
    # AR_PROMPT_GIT_DISABLED
    local git_completion_disabled="${AR_PROMPT_GIT_DISABLED:-false}"

    # AR_PROMPT_COLOR_DISABLED
    local use_color="${AR_PROMPT_COLOR_DISABLED:-$AR_PROMPT_COLOR_SUPPORTED}"

    if [ "$use_color" = "true" ] && { [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; }; then
        PS1_COLORED_HOST=$(context-color --prompt --background --context hostname)\h
    else
        PS1_COLORED_AT="$(context-color --prompt --context whoami)@"
    fi

    if [ "$git_completion_disabled" == "false" ]; then
        if [ "$use_color" = "true" ] ; then
            export GIT_PS1_SHOWCOLORHINTS=1
            __git_ps1 "${BOLD}\u${PS1_COLORED_AT}${NC}${PS1_COLORED_HOST}${NC} ${BLUE}\w${NC}" "\\$ "
        else
            __git_ps1 "\u@\h \w" "\\$ "
        fi
    else
        if [ "$use_color" = "true" ] ; then
            PS1="${BOLD}\u${PS1_COLORED_AT}${NC}${PS1_COLORED_HOST}${NC} ${BLUE}\w${NC} \\$ "
        else
            PS1="\u@\h \w \\$ "
        fi
    fi
}

PROMPT_COMMAND="__do_ps1"
