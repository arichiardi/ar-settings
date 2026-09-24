;; -*- lexical-binding: t; -*-
(require 'cl-lib)

(add-to-list 'default-frame-alist '(font . "JetBrainsMono Nerd Font Mono-12"))

(set-fontset-font "fontset-default"
                  'emoji
                  (font-spec :family "Noto Color Emoji"))

;; Show WM decorations on Linux.
;;
;; Emacs 31.1 loads site-start.el BEFORE early-init.el.  So editing
;; default-frame-alist here does not work: early-init.el runs afterwards
;; and re-adds `(undecorated . t)' at the front of the alist, and the
;; first match wins.
;;
;; Override after all user config instead.  `after-init-hook' runs after
;; early-init.el/init.el but still before frame-notice-user-settings
;; applies default-frame-alist to the initial frame; later frames pick
;; the value up from the alist.  Append (t) so our hook runs last.
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
