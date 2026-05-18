# shared whitelist
ENV_WHITELIST=(
    ALTERNATE_EDITOR
    ASDF_DATA_DIR
    CONTEXT_FILE_NAMES
    DISABLE_TELEMETRY
    EDITOR
    GIT_HOME
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
    VISUAL
)

DIR_RW_WHITELIST=(
    "$HOME/.babashka"
    "$HOME/.clojure"
    "$HOME/.config/goose"
    "$HOME/.config/pi"
    "$HOME/.deps.clj"
    "$HOME/.gitlibs"
    "$HOME/.local/bin"
    "$HOME/git"
    "$HOME/tmp"
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
    safehouse_env_pass="$(IFS=,; echo "${ENV_WHITELIST[*]}")"

    safehouse() {
        command safehouse --enable=playwright-chrome \
                --append-profile="$safehouse_agent_policy" \
                --env-pass="$safehouse_env_pass" "$@"
    }
fi

# Bubblewrap availability
if command -v bwrap >/dev/null 2>&1; then
    _BWRAP_ARGS=(
        --unshare-all
        --share-net
        --dir "/run/user/$(id -u)"
        --tmpfs /tmp                 # private /tmp (tmpfs)
        --dev /dev                   # expose /dev
        --proc /proc                 # expose /proc
        --ro-bind /usr /usr          # host /usr read‑only
        --ro-bind /bin /bin          # host /bin read‑only (for distro that still separates it)
        --ro-bind /lib /lib          # host /lib read‑only
        --ro-bind /lib64 /lib64      # host /lib64 read‑only (on amd64)
        --ro-bind "$HOME" "$HOME"    # read-only $HOME
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

        local added_env=()

        for var in "${ENV_WHITELIST[@]}"; do
            if [[ -n "${!var:-}" ]]; then
                bwrap_args+=( "--setenv" "$var" "${!var}" )
                added_env+=( "$var" )
            fi
        done

        if (( ${#added_env[@]} > 0 )); then
            echo_info "Safe env: ${added_env[@]}"
        fi

        local cmd=$1; shift

        bwrap "${bwrap_args[@]}" "${env_opts[@]}" -- "$cmd" "$@"
    }
fi
