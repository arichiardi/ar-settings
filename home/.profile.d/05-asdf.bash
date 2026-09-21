asdf_data_dir=${ASDF_DATA_DIR:-$HOME/.asdf}

# asdf is only installed as a binary on PATH (or its data dir exists)
if command -v asdf >/dev/null 2>&1 || [ -d "$asdf_data_dir" ]; then
    export PATH="$asdf_data_dir/shims":$PATH

    export ASDF_CONFIG_FILE=$HOME/.config/asdf/asdfrc

    . <(asdf completion bash)

    # Java
    # https://github.com/halcyon/asdf-java?tab=readme-ov-file#java_home
    [ -f "$asdf_data_dir/plugins/java/set-java-home.bash" ] && . "$asdf_data_dir/plugins/java/set-java-home.bash"

    # npm
    export ASDF_NPM_DEFAULT_PACKAGES_FILE=$HOME/.config/asdf/default-npm-packages
fi
