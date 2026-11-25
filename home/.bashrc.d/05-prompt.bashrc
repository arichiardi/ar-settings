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

# True when the shell runs as an account other than the one that launched it.
#
# A: /proc/self/loginuid, the kernel audit login UID, differs from EUID.
# pam_loginuid writes it at login, sshd starts a fresh value, and a normal
# process cannot write it, so a sudo crossing stays visible.
#
# B: MANAGERPID is set, and the cgroup places the shell under
# user@EUID.service, so a systemd unit of this user's own manager owns it.
# That is a machine scope. A normal login, terminal, or tmux shell is under
# user@N.slice as session-*.scope, not under user@N.service, so this does not
# fire for one even when MANAGERPID is set. Cache the verdict in the caller,
# so PROMPT_COMMAND pays the cost once per shell.
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
        # The kernel cgroup path. A scope is under user@N.service, a login or
        # terminal is under user@N.slice as session-*.scope.
        case "$(sed -n 1p /proc/self/cgroup 2>/dev/null)" in
        *"user@${EUID}.service/"*) _impersonated_cache=yes ;;
        esac
    fi
    [ "$_impersonated_cache" = yes ]
}

# Set <out-var> to the color sequence for <context>, cached in <cache-var>.
# Call it in the caller: a command substitution runs in a subshell and loses
# the cache assignment, which costs a tool call on every prompt.
# Take the color id from context-color and emit the SGR sequence directly,
# not via tput: tput is unreliable in some shells and this box's scope.
_prompt_color () {
    local _pc_out="$1" _pc_cache="$2" _pc_ctx="$3" _pc_sgr=38
    [ "$4" = "background" ] && _pc_sgr=48
    if [ -z "${!_pc_cache:-}" ]; then
        local _pc_id
        _pc_id="$(context-color --id $([ "$_pc_sgr" = 48 ] && printf -- --background) --context "$_pc_ctx" 2>/dev/null)"
        if [[ "$_pc_id" =~ ^[0-9]+$ ]]; then
            # Bare open, no reset: the template closes each slot with its own NC.
            printf -v "$_pc_cache" '%s' "\\[\\e[${_pc_sgr};5;${_pc_id}m\\]"
        else
            printf -v "$_pc_cache" '%s' _none
        fi
    fi
    [ "${!_pc_cache}" = _none ] || printf -v "$_pc_out" '%s' "${!_pc_cache}"
}

# The account name for the color hash, from bash, not from a command: a machine
# scope has a PATH with no whoami and no hostname. The result is a hash input,
# so strip anything that is not part of a name.
_prompt_name () {
    local _pn="${USERNAME:-${USER:-}}"
    _pn="${_pn//[^A-Za-z0-9._-]/}"
    [ -n "$_pn" ] || _pn="$(whoami 2>/dev/null)"
    printf '%s' "$_pn"
}

# The machine name for the color hash, from bash, then from a command.
_prompt_host () {
    local _ph="${HOSTNAME:-$(hostname 2>/dev/null)}"
    _ph="${_ph//[^A-Za-z0-9._-]/}"
    printf '%s' "$_ph"
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

    # SSH state, read once: the markers sshd puts in the shell it starts.
    local is_ssh=no
    if [ -n "${SSH_CLIENT:-}" ] || [ -n "${SSH_TTY:-}" ]; then
        is_ssh=yes
    fi

    if [ "$use_color" = "true" ]; then
        # User slot: is this the account that logged in? A machine scope carries
        # no ssh markers, so the scope check answers it, not the session.
        if _is_impersonated; then
            [ -n "${_user_name_cache:-}" ] || _user_name_cache="$(_prompt_name)"
            _prompt_color PS1_USER_BG _user_bg_color_cache "printf %s $_user_name_cache" background
        elif [ "$is_ssh" = no ]; then
            [ -n "${_user_name_cache:-}" ] || _user_name_cache="$(_prompt_name)"
            _prompt_color PS1_AT_COLOR _user_fg_color_cache "printf %s $_user_name_cache" foreground
        fi

        # Host slot: a remote session only. A local shell, including a local
        # agent scope, is not remote, so it never colors the host.
        if [ "$is_ssh" = yes ]; then
            [ -n "${_host_name_cache:-}" ] || _host_name_cache="$(_prompt_host)"
            _prompt_color PS1_HOST_COLOR _host_bg_color_cache "printf %s $_host_name_cache" background
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
