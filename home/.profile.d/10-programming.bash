# Emacs
export ALTERNATE_EDITOR=""
export EDITOR="emacsclient-daemon -nw"
export VISUAL="emacsclient-daemon -r"
export EA_EDITOR=$VISUAL

# XML
export XMLLINT_INDENT="  "

# Gtags & ctags
export GTAGSLABEL=universal-ctags

# Git
export GIT_HOME="$HOME/git"

# JetBrains
if `is_os darwin`; then
  export PATH=$PATH:"$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
fi

# OpenSpec
export OPENSPEC_TELEMETRY=0

# vercel-labs skills
export DISABLE_TELEMETRY=1

# Mistral Vibe
export VIBE_HOME="$HOME/.config/vibe"

# Goose (by block)
export GOOSE_PROVIDER=vllm-local
export GOOSE_MODEL=Qwen3.X-27B
export GOOSE_RECIPE_PATH=$HOME/.config/llm/recipes
export CONTEXT_FILE_NAMES='[".goosehints", "AGENTS.md"]'

# pi and pi-acp
export PI_ACP_ENABLE_EMBEDDED_CONTEXT=true
# https://github.com/badlogic/pi-mono/issues/2390
# export PI_CONFIG_DIR=$HOME/.config/pi
export PI_CODING_AGENT_DIR=$HOME/.config/pi/agent
export PI_CODING_AGENT_SESSION_DIR=$HOME/.pi/agent/sessions
export PI_TELEMETRY=no

# Route gpg passphrase prompts from pi to a graphical pinentry. Set the
# hint only inside pi, and only when the dispatcher that honours it is on
# PATH. macOS gets the native dialog; all other systems the GTK pinentry.
if command -v pinentry-dispatch >/dev/null 2>&1 && in_pi; then
    if is_os darwin; then
        export PINENTRY_USER_DATA=mac
    else
        export PINENTRY_USER_DATA=gtk
    fi
fi

# agent-safehouse
export SAFEHOUSE_TRUST_WORKDIR_CONFIG=no

# pnpm
if command -v pnpm >/dev/null 2>&1; then
    export PNPM_HOME="$HOME/.local/share/pnpm"
    export PATH="$PNPM_HOME/bin:$PATH"
fi
