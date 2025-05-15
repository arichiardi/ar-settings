if `is_os darwin`; then
    homebrew_dir=/opt/homebrew # hardcoding because brew --prefix is slow
fi

if `is_os darwin`; then
     pathprepend "${homebrew_dir}/opt/coreutils/libexec/gnubin" PATH
     pathprepend "${homebrew_dir}/opt/grep/libexec/gnubin" PATH
     pathprepend "${homebrew_dir}/opt/python@3.13/libexec/bin" PATH
     pathprepend "${homebrew_dir}/opt/findutils/libexec/gnubin" PATH
     pathprepend "${homebrew_dir}/opt/postgresql@17/bin" PATH
     pathprepend "${homebrew_dir}/opt/qt@6/bin" PATH
fi

# $HOME/.local/bin could be already included via /etc/profile.d
case ":${PATH}:" in
    *:"${HOME}/.local/bin":*) ;;
    *) pathprepend "${HOME}/.local/bin" PATH ;;
esac

pathprepend "$HOME/.local/lib" LD_LIBRARY_PATH

pathprepend /usr/share/man MANPATH
pathprepend "$HOME/.local/share/man" MANPATH

if `is_os darwin`; then
    # pgmodeler
    export INSTALLATION_ROOT=/Applications/pgModeler.app

    # qt
    export QT_ROOT=/opt/qt/6.8.2/macos
    pathappend "-L$QT_ROOT/lib" LDFLAGS
    pathappend "-I$QT_ROOT/include" CPPFLAGS
    pathappend "$QT_ROOT/lib/pkgconfig" PKG_CONFIG_PATH
    pathprepend "$QT_ROOT/bin" PATH

    # postgresql@17
    export LIBPQ_ROOT=${homebrew_dir}/opt/libpq
    export PGSQL_ROOT=${homebrew_dir}/opt/postgresql@17
    pathappend "-L$PGSQL_ROOT/lib" LDFLAGS
    pathappend "-I$PGSQL_ROOT/include" CPPFLAGS
fi
