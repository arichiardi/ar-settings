is_os darwin && asdf_script_dir=${HOMEBREW_PREFIX}/opt/asdf/libexec
is_os linux && asdf_script_dir=/opt/asdf-vm

# https://asdf-vm.com
source $asdf_script_dir/asdf.sh

# https://github.com/halcyon/asdf-java?tab=readme-ov-file#java_home
source $HOME/.asdf/plugins/java/set-java-home.bash
