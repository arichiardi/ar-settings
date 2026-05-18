# Emacs
ALTERNATE_EDITOR=""
EDITOR="emacsclient-daemon -nw"
VISUAL="emacsclient-daemon -r"
EA_EDITOR=$VISUAL

# XML
XMLLINT_INDENT="  "

# Gtags & ctags
GTAGSLABEL=universal-ctags

# Git
GIT_HOME="$HOME/git"

# JetBrains
if `is_os darwin`; then
  PATH=$PATH:"$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
fi

# vercel-labs skills
DISABLE_TELEMETRY=1

# Mistral Vibe
VIBE_HOME="$HOME/.config/vibe"

# Goose (by block)
GOOSE_PROVIDER=vllm-local
GOOSE_MODEL=Qwen3.X-27B
GOOSE_RECIPE_PATH=$HOME/.config/llm/recipes
CONTEXT_FILE_NAMES='[".goosehints", "AGENTS.md"]'

# pi and pi-acp
PI_ACP_ENABLE_EMBEDDED_CONTEXT=true
# https://github.com/badlogic/pi-mono/issues/2390
# export PI_CONFIG_DIR=$HOME/.config/pi
PI_CODING_AGENT_DIR=$HOME/.config/pi/agent
PI_CODING_AGENT_SESSION_DIR=$HOME/.pi/agent/sessions
PI_TELEMETRY=no
