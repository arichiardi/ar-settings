# Generic
alias commit-ts='function commit-ts-fn { local datetime=$(date --iso-8601=second); local submodule_message="Commit on $datetime"; git add . ; git commit -m "$submodule_message"; }; commit-ts-fn'

# Git
alias g='hub'
alias gitalias="git config --get-regexp ^alias\." # from http://stackoverflow.com/questions/7066325/how-to-list-show-git-aliases

# Java
export JAVA_HOME=/usr/lib/jvm/default
export NASHORN_HOME=$JAVA_HOME/bin
export M2_HOME=/usr/share/maven
export M2=$M2_HOME/bin
export MAVEN_OPTS="-Xmx2048m -Xms512m -XX:MaxPermSize=312M -XX:ReservedCodeCacheSize=128m -Dsun.lang.ClassLoader.allowArraySyntax=true -ea -Dfile.encoding=UTF-8"
export MAVEN_JMX="-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=6969 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false"

# Maven
alias mvn='notify-after mvn'
alias mc='mvn clean'
alias mci='mvn clean install'
alias mcist='mvn clean install -DskipAllTests -T3 -Dmaven.test.skip=true'
alias mcisst='mvn clean install -DskipTests -DskipITests -DskipAllTests -Dskip.checkstyle -Dcheckstyle.skip -Dpmd.skip -Djacoco.skip -T3'

# Clojure
export CLOJURE_JAR=$HOME/.m2/repository/org/clojure/clojure/1.9.0/clojure-1.9.0.jar
export CLOJURE_EXT=$CLOJURE_JAR
export CLOJURE_OPTS="-Xms128M -Xmx512M -server"

alias l='lein'
alias b='boot'
alias clj-repl='function do_repl { clojure -J-Dclojure.server.repl="{:port ${1:-5555} :accept clojure.core.server/repl}" -M:rebel:zprint; }; do_repl'
alias cljs-node-repl='function do_repl { clojure -J-Dclojure.server.repl="{:port ${1:-5555} :accept cljs.server.node/repl}" -R:cljs-canary -M:rebel-cljs -m cljs.main -re node -r; }; do_repl'

# Emacs
export ALTERNATE_EDITOR=""
export EDITOR="emacsclient-daemon.sh -nw"
export VISUAL="emacsclient-daemon.sh -c"
export EA_EDITOR="emacsclient-daemon.sh -c"

alias vi="emacsclient-daemon.sh -nw"
alias e="emacsclient-daemon.sh -nw"
alias em="emacsclient-daemon.sh -c"
alias ed="emacsclient-dired.sh"
alias emacs-resurrect='kill -CONT $(pgrep emacs | xargs)'
alias emacs-packs='cd $HOME/.emacs.d/packs'
alias emacs-ar-pack='cd $HOME/.emacs.d/.live-packs/ar-emacs-pack'

# XML
export XMLLINT_INDENT="  "

# Leiningen
export LEIN_JVM_OPTS=

# Gtags & ctags
export GTAGSLABEL=universal-ctags

# Docker
alias docker-tcp='sudo systemctl stop docker; nohup sudo docker daemon -H tcp://localhost:4243 --raw-logs > /dev/null 2>&1 &'
alias docker-rmia='docker rmi $(docker images -qf "dangling=true")'
alias docker-gateway="docker network inspect bridge --format='{{(index .IPAM.Config 0).Gateway}}'"
