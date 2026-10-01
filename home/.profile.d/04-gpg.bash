# https://wiki.archlinux.org/index.php/GnuPG#SSH_agent

# Expose the agent's ssh socket only when the agent is configured to
# provide one. GNUPGHOME is the standard GnuPG override for the config
# directory; the agent config lives in gpg-agent.conf inside it.
_gpg_agent_conf=${GNUPGHOME:-"$HOME/.gnupg"}/gpg-agent.conf
if [[ -r "$_gpg_agent_conf" ]] && grep -q enable-ssh-support "$_gpg_agent_conf"; then
  export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
fi
