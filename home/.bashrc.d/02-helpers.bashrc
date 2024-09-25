function detect_color_support {
    # Return a variable containing true if color is supported.

    # This was copied from Manjaro's .bashrc

    # Set colorful PS1 only on colorful terminals.
    # dircolors --print-database uses its own built-in database
    # instead of using /etc/DIR_COLORS.  Try to use the external file
    # first to take advantage of user additions.  Use internal bash
    # globbing instead of external grep binary.
    local use_color=
    local safe_term=${TERM//[^[:alnum:]]/?}   # sanitize TERM
    local match_lhs=""
    [[ -f ~/.dir_colors   ]] && match_lhs="${match_lhs}$(<~/.dir_colors)"
    [[ -f /etc/DIR_COLORS ]] && match_lhs="${match_lhs}$(</etc/DIR_COLORS)"
    [[ -z ${match_lhs}    ]] \
	    && type -P dircolors >/dev/null \
	    && match_lhs=$(dircolors --print-database)
    [[ $'\n'${match_lhs} == *$'\n'"TERM "${safe_term}* ]] && use_color=true

    # added
    [[ "$TERM" =~ "color" ]] && use_color=true
    echo $use_color
    return 0
}

use_color=$(detect_color_support)

# From http://blog.effy.cz/2014/07/maven-build-notifications.html
notify-after () {
    CMD=$1
    shift

    $CMD $@
    RETCODE=$?
    BUILD_DIR=${PWD##*/}
    BUILD_CMD=`basename $CMD`
    if [ $RETCODE -eq 0 ]
    then
        notify-send -c $BUILD_CMD -i emblem-default -t 1000 "$BUILD_DIR: $BUILD_CMD successful" "$(date)"
    elif [ $RETCODE -eq 130 ]
    then
        notify-send -c $BUILD_CMD -i emblem-ohno -t 1000 "$BUILD_DIR: $BUILD_CMD canceled" "$(date)"
    else
        notify-send -c $BUILD_CMD -i emblem-important -t 1000 "$BUILD_DIR: $BUILD_CMD failed" "$(date)"
    fi
    return $RETCODE
}

# Nice approach taken from here:
#
# https://stackoverflow.com/a/29239609
if_os () { [[ $OSTYPE == *$1* ]]; }
if_nix () {
    case "$OSTYPE" in
        *linux*|*hurd*|*msys*|*cygwin*|*sua*|*interix*) sys="gnu";;
        *bsd*|*darwin*) sys="bsd";;
        *sunos*|*solaris*|*indiana*|*illumos*|*smartos*) sys="sun";;
    esac
    [[ "${sys}" == "$1" ]];
}
