if `is_os linux`; then
    source "/usr/share/git/completion/git-prompt.sh"
elif `is_os darwin`; then
    export GIT_PS1_SHOWDIRTYSTATE=0 # git is very slow on MacOS
    source "/opt/git/contrib/completion/git-prompt.sh"
fi

# Prompt color sequences. Used only by __do_ps1 in this file.
NC="\[\e[0m\]"
BOLD="\[\e[1m\]"
BLUE="\[\e[34m\]"

export GIT_PS1_SHOWCONFLICTSTATE=yes
export GIT_PS1_SHOWUPSTREAM=verbose
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWSTASHSTATE=1
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_DESCRIBE_STYLE="describe"

_color_support=$(detect_color_support)

# Prompt highlight for a shell that runs as an account other than the one that
# logged in. No configuration: the kernel and systemd carry the answer.

# Echo the cgroup of this process. Overridable so tests can feed a path.
_self_cgroup () {
    sed -n 1p /proc/self/cgroup 2>/dev/null
}

# True when this shell is not the login account: a visible sudo crossing, or a
# shell started by the current user's own systemd manager. The manager PID is
# env state, so anchor it on the cgroup, which is kernel state and cannot be
# inherited. Cache the verdict in the caller, so PROMPT_COMMAND pays the cost
# once per shell.
_is_impersonated () {
    local lu
    case "${_impersonated_cache:-}" in
        yes) return 0 ;;
        no)  return 1 ;;
    esac

    lu=$(< "${_login_uid_path:-/proc/self/loginuid}") 2>/dev/null
    case "$lu" in ''|4294967295) lu='' ;; esac
    _login_uid_cache="$lu"

    _impersonated_cache=no
    if [ -n "$lu" ] && [ "$lu" != "$EUID" ]; then
        _impersonated_cache=yes
    elif [ -n "${MANAGERPID:-}" ]; then
        case "$(_self_cgroup)" in
            *"user@${EUID}.service/"*) _impersonated_cache=yes ;;
        esac
    fi
    [ "$_impersonated_cache" = yes ]
}

virtualenv_prompt() {
    # If not in a virtualenv, print nothing
    [[ "$VIRTUAL_ENV" == "" ]] && return

    # Distinguish between the shell where the virtualenv was activated
    # and its children
    local venv_name="${VIRTUAL_ENV##*/}"
    if typeset -f deactivate >/dev/null; then
        echo "[${venv_name}] "
    else
        echo "<${venv_name}> "
    fi
}

function __do_ps1 () {
    # Set AR_PROMPT_GIT_DISABLED to skip the __git_ps1 call.
    local git_completion_disabled="${AR_PROMPT_GIT_DISABLED:-false}"

    # Set AR_PROMPT_COLOR_DISABLED to force a monochrome prompt.
    if [[ "${AR_PROMPT_COLOR_DISABLED:-false}" == "true" ]]; then
        use_color=false
    else
        use_color=${_color_support:-false}
    fi

    # Reset every slot each pass. The branches below fill one slot only, so a
    # stale value leaks into the template and into child shells. PROMPT_COMMAND
    # re-runs this function for every prompt.
    PS1_AT_COLOR=""
    PS1_HOST_COLOR=""
    PS1_USER_BG=""

    # Mirror the host highlight: a background color on an impersonated name.
    # Cache the color in the caller, not in a command substitution.
    if _is_impersonated && [ "$use_color" = "true" ]; then
        if [ -z "${_user_bg_color_cache:-}" ]; then
            _user_bg_color_cache="$(context-color --prompt --background --context whoami)"
        fi
        PS1_USER_BG="$_user_bg_color_cache"
    fi

    if [ "$use_color" = "true" ]; then
        if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
            # Remote session: highlight the machine with a background color.
            PS1_HOST_COLOR=$(context-color --prompt --background --context hostname)
        elif [ -z "$PS1_USER_BG" ]; then
            # My own account, local session: a foreground color on the name.
            PS1_AT_COLOR="$(context-color --prompt --context whoami)"
        fi
    fi

    # The user name ends at NC, so a background color stops before the at sign.
    if [ "$git_completion_disabled" == "false" ]; then
        if [ "$use_color" = "true" ] ; then
            export GIT_PS1_SHOWCOLORHINTS=1
            __git_ps1 "${PS1_USER_BG}${BOLD}\u${NC}${PS1_AT_COLOR}@${NC}${PS1_HOST_COLOR}\h${NC} ${BLUE}\w${NC}" "\\$ "
        else
            __git_ps1 "\u@\h \w" "\\$ "
        fi
    else
        if [ "$use_color" = "true" ] ; then
            PS1="${PS1_USER_BG}${BOLD}\u${NC}${PS1_AT_COLOR}@${NC}${PS1_HOST_COLOR}\h${NC} ${BLUE}\w${NC} \\$ "
        else
            PS1="\u@\h \w \\$ "
        fi
    fi
    # https://virtualenvwrapper.readthedocs.io/en/latest/tips.html#enhanced-bash-zsh-prompt
    PS1='$(virtualenv_prompt)'"$PS1"
}

PROMPT_COMMAND="__do_ps1"
