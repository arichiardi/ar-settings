(add-to-list 'default-frame-alist '(font . "JetBrainsMono Nerd Font Mono-12"))

;; For some WM we want to show decorations (nil means "use decorations")
(add-to-list 'default-frame-alist '(undecorated . nil))

(set-fontset-font "fontset-default"
                  'emoji
                  (font-spec :family "Noto Color Emoji"))
