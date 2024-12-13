# https://superuser.com/a/1407685
#
# This has to be done in .bashrc or pinentry won't see the right tty
# when connecting to the server via ssh

export GPG_TTY=$(tty)
gpg-connect-agent updatestartuptty /bye >/dev/null
