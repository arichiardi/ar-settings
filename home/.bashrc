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

# AR
. "$HOME/.bashrc_ar"
