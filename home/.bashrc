# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm*|rxvt*) color_prompt=yes;;
esac

if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
else
	color_prompt=
fi

# AR uncomment to use the git prompt
git_prompt=1

# Git

PS1_TAIL='\$ '
PROMPT_COMMAND_HEAD=

if [ ! -z "$git_prompt" ]; then
    source ~/bin/git/git-prompt.sh

    GIT_PS1_SHOWUPSTREAM="verbose"
    GIT_PS1_SHOWUNTRACKEDFILES=1
    GIT_PS1_SHOWSTASHSTATE=1
    GIT_PS1_SHOWDIRTYSTATE=1
    GIT_PS1_DESCRIBE_STYLE="describe"
    PS1_TAIL='$(__git_ps1 " (%s)")\$ '
    if [ "$color_prompt" = yes ]; then
        GIT_PS1_SHOWCOLORHINTS=1
        PROMPT_COMMAND='__git_ps1 "${debian_chroot:+($debian_chroot)}\[$BOLD\]\u@\h\[$NC\] \[$BLUE\]\w\[$NC\]" "\\$ "'
    else
        PROMPT_COMMAND='__git_ps1 "${debian_chroot:+($debian_chroot)}\u@\h \w" "\\$ "'
    fi
fi

RED=`tput setaf 1`
GREEN=`tput setaf 10`
NC=`tput sgr0`
BOLD=`tput bold`
BLUE=`tput setaf 4`
ORANGE=`tput setaf 202`

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[$BOLD\]\u@\h\[$NC\]:\[$BLUE\]\w\[$NC\]'$PS1_TAIL
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w'$PS1_TAIL
fi

unset color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
    xterm*|rxvt*)
        PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
        ;;
    *)
        ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

source ~/bin/git/git-completion.bash
__git_complete g __git_main

function urxvt-keyboard-select {
    local C=$(tput setaf 6)
    local NC=$(tput sgr0)
    local B=$(tput bold)
    echo -e "\
                                                      ${C}${B}h/j/k/l${NC}:    Move cursor left/down/up/right (also with arrow keys)
                  ${C}${B}g/G/0/^/$/H/M/L/f/F/;/,/w/W/b/B/e/E${NC}: More vi-like cursor movement keys
                  ${C}${B}'/'/?${NC}:      Start forward/backward search
                  ${C}${B}n/N${NC}:        Repeat last search, N: in reverse direction
                  ${C}${B}Ctrl-f/b${NC}:   Scroll down/up one screen
                  ${C}${B}Ctrl-d/u${NC}:   Scroll down/up half a screen
                  ${C}${B}v/V/Ctrl-v${NC}: Toggle normal/linewise/blockwise selection
                  ${C}${B}y/Return${NC}:   Copy selection to primary buffer, Return: quit afterwards
                  ${C}${B}Y${NC}:          Copy selected lines to primary buffer or cursor line and quit
                  ${C}${B}q/Escape${NC}:   Quit keyboard selection mode"
}

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# Enable gpg-agent if it is not running
GPG_AGENT_SOCKET=$(gpgconf --list-dirs | grep agent-socket | cut -d ":" -f 2)
if [ ! -S $GPG_AGENT_SOCKET ]; then
  gpgconf --launch gpg-agent
  export GPG_TTY=$(tty)
fi

# Set SSH to use gpg-agent if it is configured to do so
GNUPGCONFIG=${GNUPGHOME:-"$HOME/.gnupg/gpg-agent.conf"}
if grep -q enable-ssh-support "$GNUPGCONFIG"; then
  unset SSH_AGENT_PID
  export SSH_AUTH_SOCK=$GPG_AGENT_SOCKET.ssh
fi

# From https://superuser.com/questions/509950/why-are-unicode-characters-not-rendering-correctly
LANG=en_US.UTF-8
LC_CTYPE="en_US.UTF-8"
LC_NUMERIC="en_US.UTF-8"
LC_TIME="en_US.UTF-8"
LC_COLLATE="en_US.UTF-8"
LC_MONETARY="en_US.UTF-8"
LC_MESSAGES="en_US.UTF-8"
LC_PAPER="en_US.UTF-8"
LC_NAME="en_US.UTF-8"
LC_ADDRESS="en_US.UTF-8"
LC_TELEPHONE="en_US.UTF-8"
LC_MEASUREMENT="en_US.UTF-8"
LC_IDENTIFICATION="en_US.UTF-8"
LC_ALL=en_US.UTF-8

# From http://blog.effy.cz/2014/07/maven-build-notifications.html
notify-after () {
    CMD=$1
    shift

    $CMD $@
    RETCODE=$?
    BUILD_DIR=${PWD##*/}
    BUILD_CMD=`basename $CMD`
    if [ $RETCODE -eq 0 ]
    then
        notify-send -c $BUILD_CMD -i emblem-default -t 1800000 "$BUILD_DIR: $BUILD_CMD successful" "$(date)"
    elif [ $RETCODE -eq 130 ]
    then
        notify-send -c $BUILD_CMD -i emblem-ohno -t 1800000 "$BUILD_DIR: $BUILD_CMD canceled" "$(date)"
    else
        notify-send -c $BUILD_CMD -i emblem-important -t 1800000 "$BUILD_DIR: $BUILD_CMD failed" "$(date)"
    fi
    return $RETCODE
}

# Java
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export NASHORN_HOME=$JAVA_HOME/bin
export M2_HOME=/usr/share/maven
export M2=$M2_HOME/bin
export MAVEN_OPTS="-Xmx2048m -Xms512m -XX:MaxPermSize=312M -XX:ReservedCodeCacheSize=128m -Dsun.lang.ClassLoader.allowArraySyntax=true -ea -Dfile.encoding=UTF-8"
export MAVEN_JMX="-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=6969 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false"

# Idea
# From http://stackoverflow.com/questions/5124368/gradle-doesnt-work-in-intellij-problems-with-java-home
IDEA_JDK=$JAVA_HOME
PATH=$PATH:~/.local/share/ideaIC2017.3/bin

# Path additions
# PATH=$PATH:...

# Clojure
export CLOJURE_JAR=$HOME/.m2/repository/org/clojure/clojure/1.9.0/clojure-1.9.0.jar
export CLOJURE_EXT=$CLOJURE_JAR
export CLOJURE_OPTS="-Xms128M -Xmx512M -server"

# Emacs default editor
export ALTERNATE_EDITOR=""
export EDITOR="emacsclient -a emacs -nw"
export VISUAL="emacsclient -a emacs -c"
export EA_EDITOR="$HOME/bin/emacsclient-daemon.sh -c"
export PATH="$HOME/.cask/bin:$PATH"

# Misc
export XMLLINT_INDENT="  "

# GPG
export GPGKEY=5BB502F6
export GPGKEYID=5BB502F6

function man () {
    if [ $TERM ]; then
        emacsclient -t -c -eval "(progn (setq Man-notify-method 'bully) (man \"$@\"))";
    else
        yelp "man:$@";
    fi
}

## From https://stackoverflow.com/questions/10081293/install-npm-into-home-directory-with-distribution-nodejs-package-ubuntu
# NPM_PACKAGES="$HOME/.local/share/npm-packages"
# PATH="$NPM_PACKAGES/bin:$PATH"
# MANPATH="$NPM_PACKAGES/share/man:$MANPATH"
# NODE_PATH="$NPM_PACKAGES/lib/node_modules:$NODE_PATH"

# Leiningen
export LEIN_JVM_OPTS=
# MOVED TO /etc/bash_completion.d
# source ~/bin/lein_completion.bash

# Boot
export BOOT_JVM_OPTIONS="-Xmx8g -client -XX:+TieredCompilation -XX:TieredStopAtLevel=1 -XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled -Xverify:none -XX:-OmitStackTraceInFastThrow"
export BOOT_COLOR=1
export BOOT_GPG_COMMAND=gpg2

# Docker Remote API
# DOCKER_OPTS='-H tcp://localhost:4243 -H unix:///var/run/docker.sock'

# AWS completion
complete -C '/usr/bin/aws_completer' aws

export GIT_HOME=~/git

export ANDROID_STUDIO=/usr/local/share/android-studio
export ANDROID_HOME=/usr/local/share/android-sdk
export GENYMOTION_HOME=/usr/local/share/genymotion
export PATH=$PATH:"$ANDROID_STUDIO/bin":"$ANDROID_HOME/tools":"$ANDROID_HOME/platform-tools":"$GENYMOTION_HOME"

# opam init
. $HOME/.opam/opam-init/init.sh > /dev/null 2> /dev/null || true

export NVM_DIR="/home/arichiardi/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

# gtags + global
export GTAGSCONF=~/.globalrc
export GTAGSLABEL=ctags

# tabtab source for serverless package
# uninstall by removing these lines or running `tabtab uninstall serverless`
[ -f /home/arichiardi/git/logpoc/node_modules/tabtab/.completions/serverless.bash ] && . /home/arichiardi/git/logpoc/node_modules/tabtab/.completions/serverless.bash
# tabtab source for sls package
# uninstall by removing these lines or running `tabtab uninstall sls`
[ -f /home/arichiardi/git/logpoc/node_modules/tabtab/.completions/sls.bash ] && . /home/arichiardi/git/logpoc/node_modules/tabtab/.completions/sls.bash

## nix package manager
. $HOME/.nix-profile/etc/profile.d/nix.sh

# Google Cloud SDK
PATH=$PATH:"/usr/local/share/google-cloud-sdk/bin"

# The next line enables shell command completion for gcloud.
if [ -f '/usr/local/share/google-cloud-sdk/completion.bash.inc' ]; then source '/usr/local/share/google-cloud-sdk/completion.bash.inc'; fi

# Custom load config
export LD_LIBRARY_PATH="$HOME/.local/lib"

# Yarn
PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

# VSTS
export PATH=$PATH:/home/arichiardi/.local/lib/vsts-cli/bin
source '/home/arichiardi/.local/lib/vsts-cli/vsts.completion'
