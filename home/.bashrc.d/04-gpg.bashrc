# https://wiki.archlinux.org/index.php/GnuPG#SSH_agent
#
# https://superuser.com/a/1407685
#
# GPG_TTY is still useful for pinentry-curses and pinentry-tty.
# The updatestartuptty command is skipped when using a pinentry dispatcher
# (see /usr/local/bin/pinentry-dispatch) to avoid overriding its routing logic.

export GPG_TTY=$(tty)

# updatestartuptty is skipped when the agent routes prompts through the
# pinentry dispatcher, which handles TTY routing on its own.
_gpg_agent_conf="${GNUPGHOME:-$HOME/.gnupg}/gpg-agent.conf"
if ! grep -q 'pinentry-program.*pinentry-dispatch' "$_gpg_agent_conf" 2>/dev/null; then
    gpg-connect-agent updatestartuptty /bye >/dev/null
fi
