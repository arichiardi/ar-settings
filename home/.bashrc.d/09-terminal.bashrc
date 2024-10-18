function urxvt-keyboard-select {
    local C=$(tput setaf 6)
    local NC=$(tput sgr0)
    local B=$(tput bold)
    echo -e "\
${C}${B}h/j/k/l${NC}:    Move cursor left/down/up/right (also with arrow keys)
${C}${B}g/G/0/^/$/H/M/L/f/F/;/,/w/W/b/B/e/E${NC}: More vi-like cursor movement keys
${C}${B}'/'/?${NC}:      Start forward/backward search
${C}${B}n/N${NC}:        Repeat last search, N: in reverse direction
${C}${B}Ctrl-f/b${NC}:   Scroll down/up one screen
${C}${B}Ctrl-d/u${NC}:   Scroll down/up half a screen
${C}${B}v/V/Ctrl-v${NC}: Toggle normal/linewise/blockwise selection
${C}${B}y/Return${NC}:   Copy selection to primary buffer, Return: quit afterwards
${C}${B}Y${NC}:          Copy selected lines to primary buffer or cursor line and quit
${C}${B}q/Escape${NC}:   Quit keyboard selection mode"
}
