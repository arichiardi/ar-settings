if `is_os darwin`; then
     pathprepend "${HOMEBREW_PREFIX}/opt/coreutils/libexec/gnubin" PATH
     pathprepend "${HOMEBREW_PREFIX}/opt/grep/libexec/gnubin" PATH
     pathprepend "${HOMEBREW_PREFIX}/opt/python@3.13/libexec/bin" PATH
     pathprepend "${HOMEBREW_PREFIX}/opt/findutils/libexec/gnubin" PATH
fi

# $HOME/.local/bin could be already included via /etc/profile.d
case ":${PATH}:" in
    *:"${HOME}/.local/bin":*) ;;
    *) pathprepend "${HOME}/.local/bin" PATH ;;
esac

pathprepend "$HOME/.local/lib" LD_LIBRARY_PATH

pathprepend /usr/share/man MANPATH
pathprepend "$HOME/.local/share/man" MANPATH
