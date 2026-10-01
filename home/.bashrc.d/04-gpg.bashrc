# https://wiki.archlinux.org/index.php/GnuPG#SSH_agent
#
# https://superuser.com/a/1407685
#
# GPG_TTY is still useful for pinentry-curses and pinentry-tty.
# The updatestartuptty command is skipped when using a pinentry dispatcher
# (see /usr/local/bin/pinentry-dispatch) to avoid overriding its routing logic.

export GPG_TTY=$(tty)

# Only update the agent's TTY if we're not using a dispatcher.
# The dispatcher handles TTY/display routing on its own.
if [[ ! -x /usr/local/bin/pinentry-dispatch ]]; then
    gpg-connect-agent updatestartuptty /bye >/dev/null
fi

export GNUPGCONFIG=${GNUPGHOME:-"$HOME/.gnupg/gpg-agent.conf"}
if grep -q enable-ssh-support "$GNUPGCONFIG"; then
  export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
fi

# Only update TTY again if not using a dispatcher.
if [[ ! -x /usr/local/bin/pinentry-dispatch ]]; then
    gpg-connect-agent updatestartuptty /bye >/dev/null
fi
