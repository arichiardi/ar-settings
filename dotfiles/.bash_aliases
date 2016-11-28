# Misc
alias cd..='cd ..'
alias ws='cd ~/workspace'
alias ln='ln -i'
alias uls='cd /usr/local/share'
alias gpg='gpg2'
alias rethinkdb='docker start rethinkdb'
# not needed for now - sleep 5; xdg-open http://$(docker inspect --format "{{ .NetworkSettings.IPAddress }}" rethinkdb):8080
alias postgres='sudo systemctl stop postgresql.service'
alias docker-tcp='sudo systemctl stop docker; nohup sudo docker daemon -H tcp://localhost:4243 --raw-logs > /dev/null 2>&1 &'
alias docker-rmia='docker rmi $(docker images -qf "dangling=true")'

# Clojure
alias clj='lein repl'
alias b='boot'

# Emacs
alias vi="emacsclient -t"
alias e="emacsclient -t"
alias em="emacsclient -c -a emacs"

# Android SDK
alias adbkill='sudo /usr/local/share/android-sdk/platform-tools/adb kill-server'
alias adbstart='sudo /usr/local/share/android-sdk/platform-tools/adb start-server'
alias adbrestart='adbkill;adbstart'

# Git
alias g='git'

# from http://stackoverflow.com/questions/7066325/how-to-list-show-git-aliases
alias gitalias="git config --get-regexp ^alias\."

# Maven
alias mvn='notify-after mvn'
alias mc='mvn clean'
alias mci='mvn clean install'
alias mcist='mvn clean install -DskipAllTests -T3 -Dmaven.test.skip=true'
alias mcisst='mvn clean install -DskipTests -DskipITests -DskipAllTests -Dskip.checkstyle -Dcheckstyle.skip -Dpmd.skip -Djacoco.skip -T3'
