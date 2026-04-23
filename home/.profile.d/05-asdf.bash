asdf_data_dir=${ASDF_DATA_DIR:-$HOME/.asdf}

pathprepend "$asdf_data_dir/shims" PATH

# Java
# https://github.com/halcyon/asdf-java?tab=readme-ov-file#java_home
. ~/.asdf/plugins/java/set-java-home.bash

