# Unnecessary here as it is done in .bashrc
# source "$HOME/.local/share/ar/helpers.sh"

function detect_color_support {
    # Return a variable containing true if color is supported.

    # This was copied from Manjaro's .bashrc

    # Set colorful PS1 only on colorful terminals.
    # dircolors --print-database uses its own built-in database
    # instead of using /etc/DIR_COLORS.  Try to use the external file
    # first to take advantage of user additions.  Use internal bash
    # globbing instead of external grep binary.
    local use_color=false
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
