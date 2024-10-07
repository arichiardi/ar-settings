if `is_os linux`; then
    source /usr/share/bash-completion/completions/git
    __git_complete g __git_main
elif `is_os darwin`; then
    # Here bash-completion@2 was installed but it did not work
    #   * Tried to compat dir https://stackoverflow.com/a/14970926
    #     export BASH_COMPLETION_COMPAT_DIR="/opt/homebrew/etc/bash_completion.d"
    #   * Tried to use their snippet
    #     [[ -r "/opt/homebrew/etc/profile.d/bash_completion.sh" ]] && source "/opt/homebrew/etc/profile.d/bash_completion.sh"
    #
    # The main instructions do not really say much but works (no bash-completion package installed)
    #   https://docs.brew.sh/Shell-Completion
    if type brew &>/dev/null
    then
        HOMEBREW_PREFIX="$(brew --prefix)"
        if [[ -r "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" ]]
        then
            source "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
        else
            for COMPLETION in "${HOMEBREW_PREFIX}/etc/bash_completion.d/"*
            do
                [[ -r "${COMPLETION}" ]] && source "${COMPLETION}"
            done
        fi
       __git_complete g __git_main
    fi
fi
