#!/bin/bash

ar_b2_default_exclude_regex='(.*\/\..*)|(.*\.DS_Store)|(.*\.Spotlight-V100)|(.*\.[Tt]rash.*)|(.*\/[wW][iI][pP])'
ar_b2_default_file_retention_args='--replace-newer --keep-days 365'

light_blue='\033[1;34m'
light_green='\033[1;32m'
light_red='\033[1;31m'
light_yellow='\033[1;33m'
no_color='\033[0m'

function echo_debug { printf "\r${light_blue} %s${no_color}\n" "$*"; }
function echo_info  { printf "\r${light_green} %s${no_color}\n" "$*"; }
function echo_warn  { printf "\r${light_yellow} %s${no_color}\n" "$*"; }
function echo_skip  { printf "\r${light_yellow} %s${no_color}\n" "$*"; }
function echo_ok    { printf "\r${light_green} %s${no_color}\n" "$*"; }
function echo_fail  { printf "\r${light_red} %s${no_color}\n" "$*"; }

function installing  { echo_info "Installing $1..."; }
function installnote { echo_info "   $1"; }
function skipping    { echo_skip "   already installed; skipping."; }
function success     { echo_ok   "   success!"; }

# Detects the package manager for this distro and sets:
#   pkg_mgr          - the manager binary (pacman, yay, apk, apt-get)
#   pkg_install_args - the arguments that make it install (e.g. "-S --noconfirm")
#   pkg_modifier     - "-yay" when yay is present on arch, else empty
function pkg_detect () {
    local distro

    declare -A pkgmgr
    pkgmgr=( \
      [arch]="pacman" \
      [arch-yay]="yay" \
      [alpine]="apk" \
      [debian]="apt-get" \
      [ubuntu]="apt-get" \
    )

    declare -A install_args
    install_args=( \
      [arch]="-S --noconfirm" \
      [arch-yay]="-Sy" \
      [alpine]="add --no-cache" \
      [debian]="install -y" \
      [ubuntu]="install -y" \
    )

    distro=$(cat /etc/os-release | tr [:upper:] [:lower:] | grep -Poi '(debian|ubuntu|red hat|centos|arch|alpine)' | uniq)
    pkg_modifier=
    if [ $(which yay) ]; then
	pkg_modifier=-yay
    fi

    pkg_mgr="${pkgmgr[$distro$pkg_modifier]}"
    pkg_install_args="${install_args[$distro$pkg_modifier]}"
    # Base manager without the yay wrapper - useful for plain repo queries.
    pkg_mgr_base="$pkg_mgr"
    [[ $pkg_mgr == "yay" ]] && pkg_mgr_base=pacman
    [[ $pkg_mgr ]] || return 1
}

# Runs the detected package manager with arbitrary arguments, e.g.:
#   pkg_run -q -Si sway              (query; -q means no status echo and no sudo)
#   pkg_run -q -m pacman -Si sway    (query with an explicit manager)
#   pkg_run -S --noconfirm foo       (install)
function pkg_run () {
    pkg_detect || return 1

    local quiet=
    local mgr=
    while [[ $1 == "-q" || ( $1 == "-m" && $# -ge 2 ) ]]; do
        case $1 in
            -q) quiet=1 ;;
            -m) mgr=$2; shift ;;
        esac
        shift
    done
    [[ $mgr ]] || mgr=$pkg_mgr

    local usesudo=
    # We cannot run sudo yay if there are aur packages - the following workaround is horrible.
    if [[ ! $quiet ]] && [[ ! $EUID -eq 0 ]] && [[ ! "$pkg_modifier" =~ "yay" ]]; then
        usesudo=sudo
    fi

    [[ $quiet ]] || echo_info Running: $usesudo $mgr $*
    $usesudo $mgr "$@"
}

function pkg_install () {
    local packages=$1

    pkg_detect || return 1

    if [[ $packages ]]; then
        pkg_run $pkg_install_args $@
    else
        echo_info Install command: $pkg_mgr $pkg_install_args
        echo "$pkg_mgr $pkg_install_args"
    fi
}

function init_normal_files () {
    local files=("$@")
    local diff_cmd="git difftool --no-index"

    for f in "${files[@]}"; do
	    echo $f
        dest_f="$HOME/$f"

        set +e
        local_f=$(readlink --no-newline --canonicalize-existing "$dest_f")
        exit_code=$?
        set -e
        if [ $exit_code -eq 0 ] && [ $local_f ]; then
            set +e
            (set -x; diff --new-file "$local_f" "$f" > /dev/null)
            exit_code=$?
            set -e

            local_d=$(dirname "$local_f")
            echo_info "Creating $local_d directory..."
            mkdir -p "$local_d"

            case $exit_code in
                0) echo_info "File $local_f already up-to-date";;
                1) echo_warn "File $local_f is outdated or missing - merging"; set +e; $diff_cmd "$local_f" "$f"; set -e;;
                *) echo_fail "Unidentified $f diff exit code ($exit_code) - skipping";;
            esac
        else
            echo_info "File $local_f is missing - copying"
            mkdir -p $(dirname "$dest_f")
            cp -iv "$f" "$(readlink --no-newline --canonicalize-missing "$dest_f")"
        fi
    done
}

function init_encrypted_files () {
    local files=("$@")
    local diff_cmd="git difftool --no-index"

    for f in "${encrypted_files[@]}"; do
        dest_f="$HOME/${f%.enc}"

        set +e
        existing_dest_f=$(readlink -f --no-newline --canonicalize-existing "$dest_f")
        exit_code=$?
        set -e
        
        if [ $exit_code -eq 0 ] && [ -f "$existing_dest_f" ]; then
            temp_f=$(readlink -f --no-newline --canonicalize-missing "$temp_dir/${f%.enc}")
            mkdir -p $(dirname "$temp_f")

            set +e
            $secret_bin -r -s "$f" -d "$temp_f"
            if [ $? -eq 0 ]; then
                $diff_cmd "$existing_dest_f" "$temp_f"
            fi
            shred -u -n 19 "$temp_f"
            set -e
        else
            echo_info "File $dest_f is missing - decrypting"
            mkdir -p $(dirname "$dest_f")
            set +e
            $secret_bin -r -s "$f" -d "$dest_f"
            set -e
        fi
    done
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
    # $5 extra args                   # these will be appended to the b2 sync command
    local default_extra_args="$ar_b2_default_file_retention_args --exclude-all-symlinks"

    local extra_args="${5:-$default_extra_args}"

    env \
        B2_APPLICATION_KEY_ID="$1" \
        B2_APPLICATION_KEY="$2" \
        b2-wrapper sync \
        --exclude-regex "$ar_b2_default_exclude_regex" \
        $extra_args \
        "$3" "b2://$4"
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
  if [[ ${BENCHMARK_SOURCE:-} ]]; then
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
  if [[ ${BENCHMARK_SOURCE:-} ]]; then
	  oldtimeformat="$TIMEFORMAT"
	  TIMEFORMAT="$file: %R"
	  time . "$file"
      TIMEFORMAT="$oldtimeformat"
      unset oldtimeformat
  else
	  . "$file"
  fi
}

# Echo a PINENTRY_USER_DATA prefix for commands that run in a TUI on the
# desktop, so gpg passphrase prompts use a graphical pinentry. macOS gets
# the native pinentry-mac, everything else the GTK pinentry. Emits nothing
# when the dispatcher that honours the variable is not on PATH.
pinentry_hint () {
    command -v pinentry-dispatch >/dev/null 2>&1 || return 0
    if is_os darwin; then echo 'PINENTRY_USER_DATA=mac '; else echo 'PINENTRY_USER_DATA=gtk '; fi
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
###################################
# AFTER PROFILING, COMMENTING OUT #
# BECAUSE THEY SLOW DOWN          #
###################################
#
# https://blog.flowblok.id.au/2013-02/shell-startup-scripts.html
# https://heptapod.host/flowblok/shell-startup/-/blob/branch/default/.shell/env_functions?ref_type=heads

