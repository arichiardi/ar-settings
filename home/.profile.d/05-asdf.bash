asdf_data_dir=${ASDF_DATA_DIR:-$HOME/.asdf}

export PATH="$asdf_data_dir/shims":$PATH

export ASDF_CONFIG_FILE=$HOME/.config/asdf/asdfrc

. <(asdf completion bash)

# Java
# https://github.com/halcyon/asdf-java?tab=readme-ov-file#java_home
. ~/.asdf/plugins/java/set-java-home.bash
