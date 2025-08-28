;;; core-editing.el --- Editing Behavior Configuration
;;; Commentary:
;;      Tabs, spaces, and general editing preferences

(message "Loading core-editing.el...")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Enhanced editing preferences
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(electric-pair-mode 1)                    ; Auto-close parentheses
(delete-selection-mode 1)                 ; Replace selected text
(global-auto-revert-mode 1)              ; Auto-reload changed files
(setq auto-revert-check-vc-info t)        ; Include VC info in auto-revert

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Better indentation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; - http://www.emacswiki.org/emacs/NoTabs
(setq-default tab-width 4
              standard-indent 4
              indent-tabs-mode nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Show whitespace
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq whitespace-style '(face trailing tabs tab-mark))
(global-whitespace-mode 1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Automatic formatting for Emacs Lisp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun auto-format-elisp-buffer ()
  "Automatically format Emacs Lisp buffer before saving."
  (when (eq major-mode 'emacs-lisp-mode)
    (delete-trailing-whitespace)
    (indent-region (point-min) (point-max))))

;; Enable automatic formatting on save for Emacs Lisp files
(add-hook 'before-save-hook 'auto-format-elisp-buffer)

;; Make this module available for loading with (require 'core-editing)
(provide 'core-editing)
(message "core-editing.el loaded successfully.")
