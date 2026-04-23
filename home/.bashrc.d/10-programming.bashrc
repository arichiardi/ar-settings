# Generic
alias commit-ts='function commit-ts-fn { local datetime=$(date --iso-8601=second); local submodule_message="Commit on $datetime"; git add . ; git commit -m "$submodule_message"; }; commit-ts-fn'

# Git
alias g='hub'
alias gitalias="git config --get-regexp ^alias\." # from http://stackoverflow.com/questions/7066325/how-to-list-show-git-aliases

# Maven
alias mc='mvn clean'
alias mci='mvn clean install'
alias mcist='mvn clean install -DskipAllTests -T3 -Dmaven.test.skip=true'
alias mcisst='mvn clean install -DskipTests -DskipITests -DskipAllTests -Dskip.checkstyle -Dcheckstyle.skip -Dpmd.skip -Djacoco.skip -T3'

# Clojure
alias l='lein'
alias b='boot'
alias clj-repl='function do_repl { clojure -J-Dclojure.server.repl="{:port ${1:-5555} :accept clojure.core.server/repl}" -M:home/rebel:home/zprint; }; do_repl'

# Emacs
alias vi="emacsclient-daemon.sh -nw"
alias e="emacsclient-daemon.sh -nw"
alias em="emacsclient-daemon.sh -c"
alias ed="emacsclient-dired.sh"
alias emacs-resurrect='kill -CONT $(pgrep emacs | xargs)'
alias emacs-packs='cd $HOME/.config/emacs/packs'

# Docker
alias docker-tcp='sudo systemctl stop docker; nohup sudo docker daemon -H tcp://localhost:4243 --raw-logs > /dev/null 2>&1 &'
alias docker-rmia='docker rmi $(docker images -qf "dangling=true")'
alias docker-gateway="docker network inspect bridge --format='{{(index .IPAM.Config 0).Gateway}}'"

# Misc
if `is_os linux`; then
    alias o="xdg-open"
elif `is_os darwin`; then
    alias o="open"
fi

# https://github.com/akermu/emacs-libvterm
if [[ "$INSIDE_EMACS" = 'vterm' ]] \
    && [[ -n ${EMACS_VTERM_PATH} ]] \
    && [[ -f ${EMACS_VTERM_PATH}/etc/emacs-vterm-bash.sh ]]; then
	source ${EMACS_VTERM_PATH}/etc/emacs-vterm-bash.sh
fi

# Direnv
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook bash)"
fi

# MCP
alias mcp-venv='source $HOME/.local/share/venv/mcp/bin/activate'

# Goose
if command -v goose >/dev/null 2>&1; then
  eval "$(goose completion bash)"

  goose() {
      source "$HOME/.local/share/venv/mcp/bin/activate" && command goose "$@"
  }
  alias goose-ralph-loop=$HOME/.config/llm/bin/ralph-loop.sh
  alias goose-clojure='env GOOSE_THINKING_EFFORT=low goose run --recipe ~/.config/llm/recipes/clojure-coder.yaml -s'
fi

