# Misc
alias o='xdg-open'
alias cd..='cd ..'
alias ln='ln -i'
alias uls='cd /usr/local/share'
alias gpg='gpg2'
alias vault='$HOME/bin/mount-vault /usr/local/data/vault.enc && cd /tmp/vault'
alias uvault='$HOME/bin/umount-vault ~/tmp/vault'
alias docker-tcp='sudo systemctl stop docker; nohup sudo docker daemon -H tcp://localhost:4243 --raw-logs > /dev/null 2>&1 &'
alias docker-rmia='docker rmi $(docker images -qf "dangling=true")'
alias udmb='udisksctl mount -b'
alias udub='udisksctl unmount -b'
alias btreset='sudo rmmod btusb && sudo modprobe btusb'
alias tarsnap='tarsnap --configfile ~/.backup/tarsnap.conf'
alias yarn-upi='yarn upgrade-interactive --latest'
alias head1='head -n1'
alias tail1='tail -n1'
alias emacs-resurrect='kill -CONT $(pgrep emacs | xargs)'
alias emacs-packs='cd $HOME/.emacs.d/packs'

# Clojure
alias l='lein'
alias b='boot'

# Emacs
alias vi="~/bin/emacsclient-daemon.sh -nw"
alias e="~/bin/emacsclient-daemon.sh -nw"
alias em="~/bin/emacsclient-daemon.sh -c"
alias ed="~/bin/emacsclient-dired.sh"

# Android SDK
alias adbkill='sudo /usr/local/share/android-sdk/platform-tools/adb kill-server'
alias adbstart='sudo /usr/local/share/android-sdk/platform-tools/adb start-server'
alias adbrestart='adbkill;adbstart'

# Git
alias g='hub'

# from http://stackoverflow.com/questions/7066325/how-to-list-show-git-aliases
alias gitalias="git config --get-regexp ^alias\."

# Maven
alias mvn='notify-after mvn'
alias mc='mvn --quiet clean'
alias mci='mvn --quiet clean install'
alias mcist='mvn --quiet clean install -DskipAllTests -T3 -Dmaven.test.skip=true'
alias mcisst='mvn --quiet clean install -DskipTests -DskipITests -DskipAllTests -Dskip.checkstyle -Dcheckstyle.skip -Dpmd.skip -Djacoco.skip -T3'
