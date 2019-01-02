# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# LOG="${TMPDIR:=/tmp}/profile-$USER"o

# echo "-----" >>$LOG
# echo "Caller: $0" >>$LOG
# echo " DESKTOP_SESSION: $DESKTOP_SESSION" >>$LOG
# echo " GDMSESSION: $GDMSESSION" >>$LOG
# echo " SHELL: $SHELL">>$LOG

# if running bash
if [ "$BASH" ] && [ "$BASH" != "/bin/sh" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
        # echo "Sourcing: $HOME/.bashrc" >>$LOG
	source "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin directories
PATH="$HOME/bin:$HOME/.local/bin:$PATH"

if [ -e /home/arichiardi/.nix-profile/etc/profile.d/nix.sh ]; then . /home/arichiardi/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
