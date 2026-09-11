(add-to-list 'default-frame-alist '(font . "JetBrainsMono Nerd Font Mono-12"))

(set-fontset-font "fontset-default"
                  'emoji
                  (font-spec :family "Noto Color Emoji"))

;; Emacs 31 loads site-start.el BEFORE early-init.el, so early-init's
;; `(undecorated . t)' is prepended afterwards and wins.  Override it via
;; a hook that runs after the user config but still before
;; `frame-notice-user-settings' applies the alist to the initial frame.
;; (when (>= emacs-major-version 31)
;;   (add-hook 'after-init-hook
;;             (lambda ()
;;               (setq default-frame-alist
;;                     (cons '(undecorated . nil)
;;                           (assq-delete-all 'undecorated default-frame-alist))))
;;             t))

;; Show WM decorations on Linux.
;;
;; Emacs 29-30: site-start runs AFTER frame creation, so we must patch
;; existing frames and update default-frame-alist for new ones.
;; (when (<= emacs-major-version 30)
;;   (when (eq system-type 'gnu/linux)
;;     (setq default-frame-alist
;;           (append (remove (lambda (x) (eq (car x) 'undecorated))
;;                           default-frame-alist)
;;                   '((undecorated . nil))))
;;
;;     (dolist (frame (frame-list))
;;       (modify-frame-parameters frame '((undecorated . nil))))))
