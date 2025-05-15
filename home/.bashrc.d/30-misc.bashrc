# AWS completion
complete -C '/usr/bin/aws_completer' aws

if `is_os darwin`; then
    # the variables are defined in .profile
    function install_pgmodeler_libs {
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
