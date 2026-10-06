_sandbox_agent_env_whitelist=(
    ALTERNATE_EDITOR
    ASDF_DATA_DIR
    CONTEXT_FILE_NAMES
    DISABLE_TELEMETRY
    DISPLAY
    GIT_HOME
    GIT_TERMINAL_PROMPT
    GPG_TTY
    GOOSE_MODEL
    GOOSE_PROVIDER
    GOOSE_RECIPE_PATH
    HOME
    LANG
    LOCAL_LLM_VLLM_HOST
    LOCAL_LLM_VLLM_PORT
    LOCAL_LLM_LLAMACPP_HOST
    LOCAL_LLM_LLAMACPP_PORT
    LOCAL_LLM_LLAMACPP_API_URL
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
    PINENTRY_USER_DATA
    SEARXNG_URL
    SSH_AUTH_SOCK
    USER
    WAYLAND_DISPLAY
    XDG_RUNTIME_DIR
)
export SANDBOX_AGENT_ENV_WHITELIST="${_sandbox_agent_env_whitelist[*]}"

_sandbox_agent_dir_tmpfs_binds=(
    "$HOME/.config/gh"
    "$HOME/.ssh"
)

_sandbox_agent_dir_ro_whitelist=(
    "$HOME/.tool-versions"
    "$HOME/.ssh/config"
    "$HOME/.ssh/authorized_keys"
    "/var/log/journal"
    "/run/log/journal"
    "/usr/lib/systemd"
)

for _pubkey in "$HOME/.ssh"/*.pub; do
    [[ -e "$_pubkey" ]] && _sandbox_agent_dir_ro_whitelist+=("$_pubkey")
done
unset _pubkey

[[ -n "${ASDF_DATA_DIR:-}" ]] && _sandbox_agent_dir_ro_whitelist+=("$ASDF_DATA_DIR")

_sandbox_agent_dir_rw_whitelist=(
    "$HOME/.agents"
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
    "$HOME/.ssh/known_hosts"
)

_sandbox_agent_socket_whitelist=()

_sandbox_agent_gnupg_home="${GNUPGHOME:-$HOME/.gnupg}"

if [[ -d "$_sandbox_agent_gnupg_home" ]]; then
    _sandbox_agent_dir_tmpfs_binds+=("$_sandbox_agent_gnupg_home")
    _sandbox_agent_dir_ro_whitelist+=(
        "$_sandbox_agent_gnupg_home/pubring.kbx"
        "$_sandbox_agent_gnupg_home/trustdb.gpg"
        "$_sandbox_agent_gnupg_home/gpg.conf"
        "$_sandbox_agent_gnupg_home/gpg-agent.conf"
        "$_sandbox_agent_gnupg_home/common.conf"
        "$_sandbox_agent_gnupg_home/private-keys-v1.d"
    )
    _sandbox_agent_socket_whitelist=(
        "$_sandbox_agent_gnupg_home/S.gpg-agent"
        "$_sandbox_agent_gnupg_home/S.gpg-agent.browser"
        "$_sandbox_agent_gnupg_home/S.gpg-agent.extra"
        "$_sandbox_agent_gnupg_home/S.gpg-agent.ssh"
        "$_sandbox_agent_gnupg_home/S.keyboxd"
        "$_sandbox_agent_gnupg_home/S.dirmngr"
    )
fi

export SANDBOX_AGENT_DIR_TMPFS_BINDS="${_sandbox_agent_dir_tmpfs_binds[*]}"
export SANDBOX_AGENT_DIR_RO_WHITELIST="${_sandbox_agent_dir_ro_whitelist[*]}"
export SANDBOX_AGENT_DIR_RW_WHITELIST="${_sandbox_agent_dir_rw_whitelist[*]}"
export SANDBOX_AGENT_SOCKET_WHITELIST="${_sandbox_agent_socket_whitelist[*]}"
