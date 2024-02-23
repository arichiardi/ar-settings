export QT_QPA_PLATFORMTHEME="qt5ct"
export EDITOR=/usr/bin/nano
export GTK2_RC_FILES="$HOME/.gtkrc-2.0"
# fix "xdg-open fork-bomb" export your preferred browser from here
export BROWSER=/usr/bin/firefox

#LOG="${TMPDIR:=/tmp}/profile_$USER"
#echo "-----" >>$LOG
#echo "Caller: $0" >>$LOG
#echo " DESKTOP_SESSION: $DESKTOP_SESSION" >>$LOG
#echo " GDMSESSION: $GDMSESSION" >>$LOG
#echo " SHELL: $SHELL">>$LOG
#echo " TERM: $TERM">>$LOG

export MANPATH=/home/kapitan/.local/share/man:$MANPATH

# 23-01-2021 - New variables and overrides cause I want to try HiDPI settings with my 4K.
# https://wiki.archlinux.org/index.php/HiDPI#Chromium_.2F_Google_Chrome
# https://developer.gnome.org/gtk3/stable/gtk-x11.html
#export GDK_SCALE=2
#export GDK_DPI_SCALE=0.5

# 05-01-2022 - Emacs client does not collaborate with Emacs 29.0.50 for some reason
export EMACS_SOCKET_NAME=$XDG_RUNTIME_DIR/emacs/server
