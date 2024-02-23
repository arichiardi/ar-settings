# https://wiki.archlinux.org/index.php/GnuPG#SSH_agent

export GPG_TTY=$(tty)
gpg-connect-agent updatestartuptty /bye >/dev/null

export GNUPGCONFIG=${GNUPGHOME:-"$HOME/.gnupg/gpg-agent.conf"}
if grep -q enable-ssh-support "$GNUPGCONFIG"; then
  export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
fi
