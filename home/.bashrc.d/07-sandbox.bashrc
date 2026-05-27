# shared whitelist
ENV_WHITELIST=(
    ALTERNATE_EDITOR
    ASDF_DATA_DIR
    CONTEXT_FILE_NAMES
    DISABLE_TELEMETRY
    GIT_HOME
    GPG_TTY
    GOOSE_MODEL
    GOOSE_PROVIDER
    GOOSE_RECIPE_PATH
    HOME
    LANG
    LOCAL_SERVER_HOST
    MCP_SEARCH_URL
    MC_REPO_DIR
    PATH
    PGDATABASE
    PGHOST
    PGPASSWORD
    PGPORT
    PGUSER
    PI_ACP_ENABLE_EMBEDDED_CONTEXT
    PI_CODING_AGENT_DIR
    PI_TELEMETRY
    SEARXNG_URL
    USER
)

DIR_RW_WHITELIST=(
    "$HOME/.babashka"
    "$HOME/.clojure"
    "$HOME/.config/emacs"
    "$HOME/.config/goose"
    "$HOME/.config/pi"
    "$HOME/.deps.clj"
    "$HOME/.gitlibs"
    "$HOME/.local/bin"
    "$HOME/.pi"
    "$HOME/git"
    "$HOME/tmp"
)

# Paths to completely hide (tmpfs for dirs, /dev/null for files)
_HIDDEN_PATHS=(
    "$HOME/.gnupg/secring.gpg"
)

# Sockets that need RW access for agent communication
_SENSITIVE_SOCKETS=(
    "$HOME/.gnupg/S.gpg-agent"
    "$HOME/.gnupg/S.gpg-agent.browser"
    "$HOME/.gnupg/S.gpg-agent.extra"
    "$HOME/.gnupg/S.gpg-agent.ssh"
)

# .gnupg special handling: tmpfs overlay (writable for lock files),
# then re-bind public/needed items RO on top. Private keys stay hidden.
_GNUPG_REBIND_RO=(
    "$HOME/.gnupg/pubring.kbx"
    "$HOME/.gnupg/trustdb.gpg"
    "$HOME/.gnupg/gpg.conf"
    "$HOME/.gnupg/private-keys-v1.d"
)

# helper: activate venv
init_agent_environment() {
    local venv_path="$HOME/.local/share/venv/mcp/bin/activate"
    if [[ -f "$venv_path" ]]; then
        # shellcheck source=/dev/null
        . "$venv_path" || echo "⚠️  Warning: failed to source $venv_path"
    else
        echo "⚠️  Warning: virtual‑env activation script not found at $venv_path"
    fi
}

# agent‑safehouse
if command -v safehouse >/dev/null 2>&1; then
    safehouse_agent_policy="$HOME/.config/agent-safehouse/agent-policy.sb"

    safehouse_run() {
        local safehouse_env_pass="$(IFS=,; echo "${ENV_WHITELIST[*]}")"

        echo_info "Sandbox env: $safehouse_env_pass"

        safehouse --enable=playwright-chrome \
                  --append-profile="$safehouse_agent_policy" \
                  --env-pass="$safehouse_env_pass" \
                  "$@"
    }
fi

# Bubblewrap availability
if command -v bwrap >/dev/null 2>&1; then
    _BWRAP_ARGS=(
        --unshare-uts
        --unshare-cgroup
        --share-net
        --bind "/run/user/$(id -u)" "/run/user/$(id -u)"  # includes gnupg sockets (RW for socket comm)
        --tmpfs /tmp                 # private /tmp (tmpfs)
        --dev-bind /dev /dev         # full /dev (includes /dev/tty, /dev/pts/*)
        --proc /proc                 # expose /proc
        --ro-bind /usr /usr          # host /usr read‑only
        --ro-bind /bin /bin          # host /bin read‑only (for distro that still separates it)
        --ro-bind /lib /lib          # host /lib read‑only
        --ro-bind /lib64 /lib64      # host /lib64 read‑only (on amd64)
        --ro-bind "$HOME" "$HOME"    # read-only $HOME
        --ro-bind /etc/ssl /etc/ssl  # OpenSSL config + CA certs
        --ro-bind /usr/share/ca-certificates /usr/share/ca-certificates
        --ro-bind /etc/ca-certificates       /etc/ca-certificates
        --dir /var                   # empty /var inside the sandbox
        --symlink ../tmp var/tmp     # var/tmp → /tmp
        --ro-bind /etc/resolv.conf /etc/resolv.conf
        --die-with-parent            # die when the calling script exits
    )
    
    bwrap_run() {
        local bwrap_args=( "${_BWRAP_ARGS[@]}" )

        for dir in "${DIR_RW_WHITELIST[@]}"; do
            if [[ -d "$dir" ]]; then
                bwrap_args+=( --bind "$dir" "$dir" )
            else
                echo_warn "Bind skipped: $dir does not exist"
            fi
        done

        # .gnupg: tmpfs overlay (writable for lock files, hides private keys)
        _gnupg_setup=false
        if [[ -d "$HOME/.gnupg" ]]; then
            bwrap_args+=( --tmpfs "$HOME/.gnupg" )
            _gnupg_setup=true

            # Re-bind public/needed items RO on top of the tmpfs
            for path in "${_GNUPG_REBIND_RO[@]}"; do
                if [[ -e "$path" ]]; then
                    bwrap_args+=( --ro-bind "$path" "$path" )
                fi
            done

            # Sockets get RW bind on top
            for socket in "${_SENSITIVE_SOCKETS[@]}"; do
                if [[ -e "$socket" ]]; then
                    bwrap_args+=( --bind "$socket" "$socket" )
                fi
            done
        fi

        for path in "${_HIDDEN_PATHS[@]}"; do
            if [[ -d "$path" ]]; then
                bwrap_args+=( --tmpfs "$path" )
            elif [[ -f "$path" ]]; then
                bwrap_args+=( --ro-bind /dev/null "$path" )
            fi
        done

        local added_env=()

        for var in "${ENV_WHITELIST[@]}"; do
            if [[ -n "${!var:-}" ]]; then
                bwrap_args+=( "--setenv" "$var" "${!var}" )
                added_env+=( "$var" )
            fi
        done

        if (( ${#added_env[@]} > 0 )); then
            echo_info "Sandbox env: ${added_env[@]}"
        fi

        local cmd=$1; shift

        if $_gnupg_setup; then
            bwrap "${bwrap_args[@]}" "${env_opts[@]}" -- /bin/bash -c '
                chmod 700 "$HOME/.gnupg"
                exec "$@"
            ' _ "$cmd" "$@"
        else
            bwrap "${bwrap_args[@]}" "${env_opts[@]}" -- "$cmd" "$@"
        fi
    }
fi
