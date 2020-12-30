# Misc
alias o='xdg-open'
alias cd..='cd ..'
alias ln='ln -i'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias uls='cd /usr/local/share'
alias gpg='gpg2'
alias udmb='udisksctl mount -b'
alias udub='udisksctl unmount -b'
alias btreset='sudo rmmod btusb && sudo modprobe btusb'
alias yarn-upi='yarn upgrade-interactive --latest'
alias yarn-gupi='yarn global upgrade-interactive --latest'
alias head1='head -n1'
alias tail1='tail -n1'
alias load-env='function load-env { export $(cat $1 | grep -v ^# | xargs); }; load-env'
alias commit-ts='function commit-ts-fn { local datetime=$(date --iso-8601=second); local submodule_message="Commit on $datetime"; git add . ; git commit -m "$submodule_message"; }; commit-ts-fn'

# Clojure
alias l='lein'
alias b='boot'
alias clj-repl='function do_repl { clojure -J-Dclojure.server.repl="{:port ${1:-5555} :accept clojure.core.server/repl}" -M:rebel; }; do_repl'
alias cljs-node-repl='function do_repl { clojure -J-Dclojure.server.repl="{:port ${1:-5555} :accept cljs.server.node/repl}" -R:cljs-canary -M:rebel-cljs -m cljs.main -re node -r; }; do_repl'

# Emacs
alias vi="emacsclient-daemon.sh -nw"
alias e="emacsclient-daemon.sh -nw"
alias em="emacsclient-daemon.sh -c"
alias ed="emacsclient-dired.sh"
alias emacs-resurrect='kill -CONT $(pgrep emacs | xargs)'
alias emacs-packs='cd $HOME/.emacs.d/packs'
alias emacs-ar-pack='cd $HOME/.emacs.d/.live-packs/ar-emacs-pack'

# Lsp
alias lsp-java-tail="tail -f ~/.emacs.d/etc/workspace/.metadata/.log"

# Git
alias g='hub'

# from http://stackoverflow.com/questions/7066325/how-to-list-show-git-aliases
alias gitalias="git config --get-regexp ^alias\."

# Maven
alias mvn='notify-after mvn'
alias mc='mvn clean'
alias mci='mvn clean install'
alias mcist='mvn clean install -DskipAllTests -T3 -Dmaven.test.skip=true'
alias mcisst='mvn clean install -DskipTests -DskipITests -DskipAllTests -Dskip.checkstyle -Dcheckstyle.skip -Dpmd.skip -Djacoco.skip -T3'

# Docker
alias docker-tcp='sudo systemctl stop docker; nohup sudo docker daemon -H tcp://localhost:4243 --raw-logs > /dev/null 2>&1 &'
alias docker-rmia='docker rmi $(docker images -qf "dangling=true")'
