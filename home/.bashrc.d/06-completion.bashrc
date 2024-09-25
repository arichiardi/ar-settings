if `is_os darwin`; then
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
    fi
fi

if `is_os linux`; then
    source /usr/share/bash-completion/completions/git
    __git_complete g __git_main
fi
