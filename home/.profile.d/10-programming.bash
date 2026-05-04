# Emacs
export ALTERNATE_EDITOR=""
export EDITOR="emacsclient-daemon.sh -nw"
export VISUAL="emacsclient-daemon.sh -c"
export EA_EDITOR="emacsclient-daemon.sh -c"

# XML
export XMLLINT_INDENT="  "

# Gtags & ctags
export GTAGSLABEL=universal-ctags

# Git
GIT_HOME="$HOME/git"

# JetBrains
if `is_os darwin`; then
  PATH=$PATH:"$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
fi

# vercel-labs skills
DISABLE_TELEMETRY=1

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

# Ralph Loop
export RALPH_WORKER_PROVIDER=github_copilot      # Provider for work phase (prompts if not set)
export RALPH_WORKER_MODEL=claude-sonnet-4.5      # Model for work phase (prompts if not set)
export RALPH_REVIEWER_PROVIDER=custom_local_vllm # Provider for review phase (prompts if not set)
export RALPH_REVIEWER_MODEL=Qwen3.5-27B          # Model for review phase (prompts if not set)
export RALPH_MAX_ITERATIONS=10                   # Max iterations (default: 10)
export RALPH_RECIPE_DIR=$GOOSE_RECIPE_PATH       # Recipe directory (default: ~/.config/goose/recipes)
