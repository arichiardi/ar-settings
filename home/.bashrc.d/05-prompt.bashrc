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
# user-N.slice as session-*.scope, not under user@N.service, so this does not
# fire for one even when MANAGERPID is set. Cache the verdict in the caller,
# so PROMPT_COMMAND pays the cost once per shell.
_is_impersonated () {
    local lu
    case "${_impersonated_cache:-}" in
        yes) return 0 ;;
        no)  return 1 ;;
    esac

    lu=$(cat "${_login_uid_path:-/proc/self/loginuid}" 2>/dev/null)
    case "$lu" in ''|4294967295) lu='' ;; esac

    _impersonated_cache=no
    if [ -n "$lu" ] && [ "$lu" != "$EUID" ]; then
        _impersonated_cache=yes
    elif [ -n "${MANAGERPID:-}" ]; then
        # The kernel cgroup path. A scope is under user@N.service, a login or
        # terminal is under user-N.slice as session-*.scope.
        case "$(sed -n 1p /proc/self/cgroup 2>/dev/null)" in
        *"user@${EUID}.service/"*) _impersonated_cache=yes ;;
        esac
    fi
    [ "$_impersonated_cache" = yes ]
}

# The tool bumps forced ids past its default excludes (0, 7, 15), so
# pre-subtract and the map id is the shown id. Fills _prompt_force_out.
_prompt_force_arg () {
    case "$1" in
        0|7|15) return 1 ;;
        1) _prompt_force_out=0 ;;
        2|3|4|5|6) _prompt_force_out=$(( $1 - 1 )) ;;
        8) _prompt_force_out=6 ;;
        9|10|11|12|13|14) _prompt_force_out=$(( $1 - 2 )) ;;
        *) _prompt_force_out=$(( $1 - 3 )) ;;
    esac
}

# AR_PROMPT_COLORS: whitespace-separated name:ID tokens, ID 0-255, that map
# a name to a fixed color instead of the hash. The value may start with
# fg or bg (name:fg:ID, like the SGR order): that overrides the slot's
# fg/bg for the name; omitted means the slot default. "*" maps unmapped
# names. 0, 7, 15 are unreachable (the tool's default excludes). Read at
# runtime: exporting a new value recolors the next prompt. Fills
# _prompt_map_out with the tool force argument, empty for an unmapped name,
# and _prompt_map_mode, empty when the token sets no mode.
_prompt_map () {
    _prompt_map_out=''
    _prompt_map_mode=''
    local _pm_name="$1" _pm_tok _pm_id _pm_dflt='' _pm_dmode='' _pm_mode_of=''
    for _pm_tok in ${AR_PROMPT_COLORS:-}; do
        case "$_pm_tok" in *:*) ;; *) continue ;; esac
        _pm_id="${_pm_tok#*:}"
        _pm_mode_of=''
        case "$_pm_id" in
            *:*)
                _pm_mode_of="${_pm_id%%:*}"
                _pm_id="${_pm_id#*:}"
                case "$_pm_mode_of" in fg|bg) ;; *) continue ;; esac
                ;;
        esac
        [[ "$_pm_id" =~ ^[0-9]+$ ]] && [ "$_pm_id" -le 255 ] || continue
        case "${_pm_tok%%:*}" in
            "$_pm_name")
                _prompt_force_arg "$_pm_id" && {
                    _prompt_map_out="$_prompt_force_out"
                    _prompt_map_mode="$_pm_mode_of"
                    return
                }
                ;;
            '*')
                if [ -z "$_pm_dflt" ]; then
                    _prompt_force_arg "$_pm_id" && {
                        _pm_dflt="$_prompt_force_out"
                        _pm_dmode="$_pm_mode_of"
                    }
                fi
                ;;
        esac
    done
    _prompt_map_out="$_pm_dflt"
    _prompt_map_mode="$_pm_dmode"
}

# Set <out-var> to the color sequence for the name <name>, cached in
# <cache-var>. A mapped name (AR_PROMPT_COLORS) forces its id; an unmapped
# name keeps the hash of its own name. A mapped name's mode overrides the
# slot's fg/bg. Call it in the caller: a command substitution runs in a
# subshell and loses the cache assignment, which costs a tool call on every
# prompt.
_prompt_color () {
    local _pc_out="$1" _pc_cache="$2" _pc_name="$3" _pc_bg=""
    [ "$4" = "background" ] && _pc_bg="--background"
    if [ -z "${!_pc_cache:-}" ]; then
        _prompt_map "$_pc_name"
        # A name mode overrides the slot default; empty means keep it.
        case "$_prompt_map_mode" in bg) _pc_bg="--background" ;; fg) _pc_bg='' ;; esac
        if [ -n "$_prompt_map_out" ]; then
            printf -v "$_pc_cache" '%s' "$(context-color --prompt $_pc_bg --force "$_prompt_map_out" 2>/dev/null)"
        else
            printf -v "$_pc_cache" '%s' "$(context-color --prompt $_pc_bg --context "printf %s $_pc_name" 2>/dev/null)"
        fi
        # Cache a tool call that yields nothing, so it is not retried on every
        # prompt. No color sequence starts with an underscore.
        [ -n "${!_pc_cache}" ] || printf -v "$_pc_cache" '%s' _none
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
    # stale value leaks into the template. PROMPT_COMMAND re-runs this
    # function for every prompt.
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
            [ -n "${_user_name_cache+set}" ] || _user_name_cache="$(_prompt_name)"
            # Slot default is background; a :fg map entry overrides it.
            _prompt_color PS1_USER_BG _user_bg_color_cache "$_user_name_cache" background
        elif [ "$is_ssh" = no ]; then
            [ -n "${_user_name_cache+set}" ] || _user_name_cache="$(_prompt_name)"
            _prompt_color PS1_AT_COLOR _user_fg_color_cache "$_user_name_cache" foreground
        fi

        # Host slot: a remote session only. A local shell, including a local
        # agent scope, is not remote, so it never colors the host.
        if [ "$is_ssh" = yes ]; then
            [ -n "${_host_name_cache+set}" ] || _host_name_cache="$(_prompt_host)"
            _prompt_color PS1_HOST_COLOR _host_bg_color_cache "$_host_name_cache" background
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
