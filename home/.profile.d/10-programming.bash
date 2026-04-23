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
export GIT_HOME="$HOME/git"

# JetBrains
if `is_os darwin`; then
  pathappend "$HOME/Library/Application Support/JetBrains/Toolbox/scripts" PATH
fi

# Mistral Vibe
export VIBE_HOME="$HOME/.config/vibe"

# Goose (by block)
export GOOSE_PROVIDER=vllm-local
export GOOSE_MODEL=Qwen3.X-27B
export GOOSE_RECIPE_PATH=$HOME/.config/llm/recipes
export CONTEXT_FILE_NAMES='[".goosehints", "AGENTS.md"]'

# Ralph Loop
export RALPH_WORKER_PROVIDER=github_copilot      # Provider for work phase (prompts if not set)
export RALPH_WORKER_MODEL=claude-sonnet-4.5      # Model for work phase (prompts if not set)
export RALPH_REVIEWER_PROVIDER=custom_local_vllm # Provider for review phase (prompts if not set)
export RALPH_REVIEWER_MODEL=Qwen3.5-27B          # Model for review phase (prompts if not set)
export RALPH_MAX_ITERATIONS=10                   # Max iterations (default: 10)
export RALPH_RECIPE_DIR=$GOOSE_RECIPE_PATH       # Recipe directory (default: ~/.config/goose/recipes)
