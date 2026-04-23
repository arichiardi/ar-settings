if `is_os darwin`; then
    homebrew_dir=/opt/homebrew # hardcoding because brew --prefix is slow
fi

if `is_os darwin`; then
     pathprepend "${homebrew_dir}/opt/coreutils/libexec/gnubin" PATH
     pathprepend "${homebrew_dir}/opt/grep/libexec/gnubin" PATH
     pathprepend "${homebrew_dir}/opt/python@3/libexec/bin" PATH
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
    # all libraries and includes
    export LDFLAGS="-L${homebrew_dir}/lib $LDFLAGS"
    export CPPFLAGS="-I${homebrew_dir}/include $CPPFLAGS"
    export CXXFLAGS=$CPPFLAGS
    export CMAKE_CXX_FLAGS="-std=c++11 -stdlib=libc++"

    # pgsql
    export PGSQL_ROOT=/opt/homebrew/Cellar/libpq/18.1

    # openssl
    export OPENSSL_ROOT=/opt/homebrew/Cellar/openssl@3/3.6.1

    # qt
    export QT_ROOT=/opt/qt/6.8.2/macos
    export QMAKE_CXXFLAGS=$CMAKE_CXX_FLAGS
    export LDFLAGS="$LDFLAGS -L$QT_ROOT/lib"o
    export CPPFLAGS="$CPPFLAGS -I$QT_ROOT/include -std=c++11 -stdlib=libc++"

    # pgmodeler
    export INSTALLATION_ROOT=/Applications/pgModeler.app
    export PGMODELER_SOURCE=$HOME/git/pgmodeler

    pathappend "$QT_ROOT/lib/pkgconfig" PKG_CONFIG_PATH
    pathprepend "$QT_ROOT/bin" PATH
fi
