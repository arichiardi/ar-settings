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

    function copy_pgmodeler_libs {
        cp -v $LIBPQ_ROOT/lib/libpq.5.dylib $INSTALLATION_ROOT/Contents/Frameworks
        cp -v $homebrew_dir/lib/libssl.3.* $INSTALLATION_ROOT/Contents/Frameworks
        cp -v $homebrew_dir/lib/libcrypto.3.* $INSTALLATION_ROOT/Contents/Frameworks

        install_name_tool -change "@loader_path/../lib/libcrypto.1.1.dylib" "@loader_path/../Frameworks/libcrypto.1.1.dylib" $INSTALLATION_ROOT/Contents/Frameworks/libssl.3.dylib
        install_name_tool -change "@loader_path/../lib/libcrypto.1.1.dylib" "@loader_path/../Frameworks/libcrypto.1.1.dylib" $INSTALLATION_ROOT/Contents/Frameworks/libpq.5.dylib
        install_name_tool -change "@loader_path/../lib/libssl.1.1.dylib" "@loader_path/../Frameworks/libssl.1.1.dylib" $INSTALLATION_ROOT/Contents/Frameworks/libpq.5.dylib
        install_name_tool -change libpq.5.dylib "@loader_path/../Frameworks/libpq.5.dylib" $INSTALLATION_ROOT/Contents/Frameworks/libconnector.dylib

        mkdir $INSTALLATION_ROOT/PlugIns/tls
        cp -rv $QT_ROOT/plugins/tls/* $INSTALLATION_ROOT/PlugIns/tls
    }
fi
