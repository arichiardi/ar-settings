#!/bin/bash

light_green='\033[1;32m'
light_red='\033[1;31m'
light_yellow='\033[1;33m'
no_color='\033[0m'

function echo_info  { printf "\r${light_green} %s${no_color}\n" "$*"; }
function echo_warn  { printf "\r${light_yellow} %s${no_color}\n" "$*"; }
function echo_skip  { printf "\r${light_yellow} %s${no_color}\n" "$*"; }
function echo_ok    { printf "\r${light_green} %s${no_color}\n" "$*"; }
function echo_fail  { printf "\r${light_red} %s${no_color}\n" "$*"; }

function installing  { echo_info "Installing $1..."; }
function installnote { echo_info "   $1"; }
function skipping    { echo_skip "   already installed; skipping."; }
function success     { echo_ok   "   success!"; }

function pkg_install () {
    local packages=$1

    local distro;
    local cmd;
    local usesudo=

    declare -A pkgmgr
    pkgmgr=( \
      [arch]="pacman -S --noconfirm" \
      [arch-yay]="yay -Sy" \
      [alpine]="apk add --no-cache" \
      [debian]="apt-get install -y" \
      [ubuntu]="apt-get install -y" \
    )

    distro=$(cat /etc/os-release | tr [:upper:] [:lower:] | grep -Poi '(debian|ubuntu|red hat|centos|arch|alpine)' | uniq)
    modifier=
    if [ $(which yay) ]; then
	modifier=-yay
    fi

    cmd="${pkgmgr[$distro$modifier]}"
    [[ ! $cmd ]] && return 1

    if [[ $packages ]]; then
	# We cannot run sudo yay if there are aur packages - the following workaround is horrible.
        if [[ ! $EUID -eq 0 ]] && [[ ! "$modifier" =~ "yay" ]]; then
            usesudo=sudo
	fi
        echo_info Installing package with: $usesudo $cmd $@
        $usesudo $cmd $@
    else
        echo_info Installing package with: $cmd
        echo $cmd
    fi
}

# The following replaces "readlink -f" behavior for macOS
# see https://stackoverflow.com/a/22971167/1888507
_canonicalize_dir_path() {
    (cd "$1" 2>/dev/null && pwd -P)
}

_canonicalize_file_path() {
    local dir file
    dir=$(dirname -- "$1")
    file=$(basename -- "$1")
    (cd "$dir" 2>/dev/null && printf '%s/%s\n' "$(pwd -P)" "$file")
}

canonicalize_path() {
    if [ -d "$1" ]; then
        _canonicalize_dir_path "$1"
    else
        _canonicalize_file_path "$1"
    fi
}

function cleanup_after_error() {
    # $1 The dir to remove
    rm -rf "$1"
    exit 1
}

function sync_dir_to_b2 () {
    # $1 B2_APPLICATION_KEY_ID
    # $2 B2_APPLICATION_KEY
    # $3 source dir
    # $4 target bucket or bucket path
    # $5 exclude symlinks
    local exclude_symlinks=${5:-true}

    local extra_args=
    if [ "$exclude_symlinks" == true ]; then
        extra_args=--exclude-all-symlinks
    fi
    env \
      B2_APPLICATION_KEY_ID="$1" \
      B2_APPLICATION_KEY="$2" \
      b2-wrapper sync \
      --threads 3 \
      --replace-newer \
      --keep-days 365 \
      --exclude-regex "(.*\/\..*)|(.*\.DS_Store)|(.*\.Spotlight-V100)|(.*\.Trash.*)|(.*\/wip)|(.*\/WIP)" \
      $extra_args \
      "$3" "b2://$4"
}

function merge_keepass_dbs () {
    # $1 the destination dir (these files will be updated)
    # $2 the source dir where secrets are taken from
    local dest_dir=$1
    local source_dir=$2

    declare -a dest_paths
    while IFS= read -r -d '' file_name; do
        dest_paths+=( "$file_name" )
    done < <(find $dest_dir -maxdepth 1 \
                  -name '*.kdbx' \
                  -print0)

    for dest_path in "${dest_paths[@]}"; do
        dest_name=$(basename "$dest_path")
        source_path=$source_dir/$dest_name

        if [ -f "$dest_path" ] && [ -f "$source_path" ]; then
            if [ "$(sha256sum $dest_path)" != "$(sha256sum $source_path)" ]; then
                keepassxc-cli merge --same-credentials "$dest_path" "$source_path"
            else
                echo_info "Database $dest_path had not been changed, skipping..."
            fi
        else
            echo_warn "Either destination ($dest_path) or source ($source_path) did not exist, skipping..."
        fi
    done
}

function merge_b2_secrets () {
    # $1 B2_APPLICATION_KEY_ID
    # $2 B2_APPLICATION_KEY
    # $3 the source bucket
    # $4 the secret dir (these files will be updated)
    local source_bucket=$3
    local target_dir=$4

    tmp_dir=$(mktemp -d -t "b2-secrets-XXXXX")
    if [[ ! "$tmp_dir" || ! -d "$tmp_dir" ]]; then
        echo_fail "Could not create temp dir"
    else
        trap "cleanup_after_error $tmp_dir" SIGINT SIGHUP SIGPIPE SIGQUIT SIGTERM

        # overriding $tmp_dir files
        env B2_APPLICATION_KEY_ID="$1" B2_APPLICATION_KEY="$2" \
          b2-wrapper sync \
            --replace-newer \
            --exclude-regex "(.*bin\/.*)|(vault\.enc)" \
            --exclude-all-symlinks \
            "b2://$source_bucket" "$tmp_dir"

        merge_keepass_dbs "$target_dir" "$tmp_dir"

        rm -rf $tmp_dir
    fi
}

function merge_rclone_secrets () {
    # $1 the rclone remote name
    # $2 the secret dir (these files will be updated)
    local rclone_remote_path=$1
    local target_dir=$2

    tmp_dir=$(mktemp -d -t "rclone-secrets-XXXXX")
    if [[ ! "$tmp_dir" || ! -d "$tmp_dir" ]]; then
        echo_fail "Could not create temp dir"
    else
        trap "cleanup_after_error $tmp_dir" SIGINT SIGHUP SIGPIPE SIGQUIT SIGTERM

        # overriding $tmp_dir files
        rclone copy \
          --no-check-dest \
          --no-update-modtime \
          --exclude "(.*bin\/.*)|(vault\.enc)" \
          --max-size 10M \
          "$rclone_remote_path" "$tmp_dir"

        merge_keepass_dbs "$target_dir" "$tmp_dir"

        rm -rf $tmp_dir
    fi
}

# Combining
#   https://wpyoga.dev/blog/2021/07/10/bashrc-directory#simple-implementation
#   https://byparker.com/blog/2021/the-power-of-bashrc-d/
#
# Run benchmark with
#   __bashrc_bench=1 . ~/.bashrc

source_if_there() {
  local file="$1"
  if [ -f "$file" ]; then
    source "$file"
  fi
}

source_sub_with_bench() {
  local superfile="$1"
  local file="$2"
  if [[ $__bashrc_bench ]]; then
    oldtimeformat="$TIMEFORMAT"
		TIMEFORMAT="$superfile $file: %R"
		time . "$file"
    TIMEFORMAT="$oldtimeformat"
    unset oldtimeformat
	else
		. "$file"
	fi
}

source_with_bench() {
  local file="$1"
  if [[ $BENCHMARK_SOURCE ]]; then
		oldtimeformat="$TIMEFORMAT"
		TIMEFORMAT="$file: %R"
		time . "$file"
    TIMEFORMAT="$oldtimeformat"
    unset oldtimeformat
	else
		. "$file"
	fi
}

# Nice approach taken from here: https://stackoverflow.com/a/29239609
is_os () { [[ $OSTYPE == *$1* ]]; }
is_nix () {
    case "$OSTYPE" in
        *linux*|*hurd*|*msys*|*cygwin*|*sua*|*interix*) sys="gnu";;
        *bsd*|*darwin*) sys="bsd";;
        *sunos*|*solaris*|*indiana*|*illumos*|*smartos*) sys="sun";;
    esac
    [[ "${sys}" == "$1" ]];
}

# Thank you flowblok!
#
# https://blog.flowblok.id.au/2013-02/shell-startup-scripts.html
# https://heptapod.host/flowblok/shell-startup/-/blob/branch/default/.shell/env_functions?ref_type=heads

# Usage: indirect_expand PATH -> $PATH
indirect_expand () {
    env |sed -n "s/^$1=//p"
}

# Usage: pathremove /path/to/bin [PATH]
# Eg, to remove ~/bin from $PATH
#     pathremove ~/bin PATH
pathremove () {
    local IFS=':'
    local newpath
    local dir
    local var=${2:-PATH}
    # Bash has ${!var}, but this is not portable.
    for dir in `indirect_expand "$var"`; do
        IFS=''
        if [ "$dir" != "$1" ]; then
            newpath=$newpath:$dir
        fi
    done
    export $var=${newpath#:}
}

# Usage: pathprepend /path/to/bin [PATH]
# Eg, to prepend ~/bin to $PATH
#     pathprepend ~/bin PATH
pathprepend () {
    # if the path is already in the variable,
    # remove it so we can move it to the front
    pathremove "$1" "$2"
    #[ -d "${1}" ] || return
    local var="${2:-PATH}"
    local value=`indirect_expand "$var"`
    export ${var}="${1}${value:+:${value}}"
}

# Usage: pathappend /path/to/bin [PATH]
# Eg, to append ~/bin to $PATH
#     pathappend ~/bin PATH
pathappend () {
    pathremove "${1}" "${2}"
    #[ -d "${1}" ] || return
    local var=${2:-PATH}
    local value=`indirect_expand "$var"`
    export $var="${value:+${value}:}${1}"
}
