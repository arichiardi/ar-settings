export QT_QPA_PLATFORMTHEME="qt5ct"
export EDITOR=/usr/bin/nano
export GTK2_RC_FILES="$HOME/.gtkrc-2.0"
# fix "xdg-open fork-bomb" export your preferred browser from here
export BROWSER=/usr/bin/chromium

#LOG="${TMPDIR:=/tmp}/profile_$USER"
#echo "-----" >>$LOG
#echo "Caller: $0" >>$LOG
#echo " DESKTOP_SESSION: $DESKTOP_SESSION" >>$LOG
#echo " GDMSESSION: $GDMSESSION" >>$LOG
#echo " SHELL: $SHELL">>$LOG
#echo " TERM: $TERM">>$LOG

export MANPATH=/home/kapitan/.local/share/man:$MANPATH

# gpg-agent - it is in .profile cause we need it in Emacs.
# https://wiki.archlinux.org/index.php/GnuPG#SSH_agent
export GPG_AGENT_SOCKET=$(gpgconf --list-dirs | grep agent-socket | cut -d ":" -f 2)
if [ ! -S $GPG_AGENT_SOCKET ]; then
  gpgconf --launch gpg-agent
  export GPG_TTY=$(tty)
fi

export GNUPGCONFIG=${GNUPGHOME:-"$HOME/.gnupg/gpg-agent.conf"}
if grep -q enable-ssh-support "$GNUPGCONFIG"; then
  export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
fi

# 23-01-2021 - New variables and overrides cause I want to try HiDPI settings with my 4K.
# https://wiki.archlinux.org/index.php/HiDPI#Chromium_.2F_Google_Chrome
# https://developer.gnome.org/gtk3/stable/gtk-x11.html
export GDK_SCALE=2
export GDK_DPI_SCALE=0.5
