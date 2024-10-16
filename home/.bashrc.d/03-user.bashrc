# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

export GIT_HOME="$HOME/git"

# Custom load config
export LD_LIBRARY_PATH="$HOME/.local/lib"


is_os darwin && export PATH="${HOMEBREW_PREFIX}/opt/coreutils/libexec/gnubin:\
${HOMEBREW_PREFIX}/opt/grep/libexec/gnubin:\
${HOMEBREW_PREFIX}/opt/python@3.13/libexec/bin:\
${HOMEBREW_PREFIX}/opt/findutils/libexec/gnubin:\
${PATH}"

# On linux, $HOME/.local/bin is included via /etc/profile.d but other systems just include it if
# missing.
#
case ":${PATH}:" in
    *:"${HOME}/.local/bin":*) ;;
    *) export PATH="${HOME}/.local/bin:${PATH}" ;;
esac
