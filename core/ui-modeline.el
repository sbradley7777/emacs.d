;;; ui-modeline.el --- Modeline Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Modeline customization and status indicators.
;;      Consolidates all modeline-related configuration for global modeline display.
;;      Note: Buffer-specific modelines (treemacs, imenu-list) are configured in their respective modules.

(core-utils-with-load-timing
 "ui-modeline.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Basic Modeline Settings
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Enable column number display in modeline
 (column-number-mode 1)

 ;; Enable line number display in modeline
 (line-number-mode 1)

 ;; Enable buffer size indication in modeline
 (size-indication-mode 1)

 ;; Display the time in modeline with custom format (YYYY-MM-dd HH:MM)
 (setq display-time-format "  %Y-%m-%d %H:%M") ; Leading spaces for separation
 (display-time)

 ;; Enable which-function-mode to show current function name
 (which-function-mode 1)

 ;; Only enable which-function-mode in programming modes (prevents errors in non-code buffers like treemacs)
 (setq
  which-func-modes
  '(emacs-lisp-mode
    lisp-interaction-mode
    python-mode
    python-ts-mode
    bash-mode
    sh-mode
    c-mode
    c++-mode
    java-mode
    javascript-mode
    typescript-mode
    js-mode
    js2-mode
    go-mode
    rust-mode
    ruby-mode
    perl-mode
    makefile-mode))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Python Virtual Environment Indicator
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Add custom Python virtual environment indicator to mode line
 (add-to-list
  'mode-line-misc-info
  '(:eval
    (when
     (and
      (local-variable-p 'pyvenv-current-project-name)
      pyvenv-current-project-name
      (not (string= pyvenv-current-project-name "inactive")))
     (propertize
      (concat
       "[venv: " pyvenv-current-project-name
       (when pyvenv-current-version (concat " (py" pyvenv-current-version ")")) "] ")
      'face
      (when
       (and
        (boundp 'pyvenv-modeline-color) pyvenv-modeline-color)
       `(:foreground ,pyvenv-modeline-color))))))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; System Information Indicator
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Add username and hostname to mode line (non-destructive approach)
 (add-to-list
  'mode-line-misc-info
  '(:eval
    (concat
     "[" (user-login-name) "@" (or (file-remote-p default-directory 'host) (system-name)) "] ")))

 ;; Make this module available for loading with (require 'ui-modeline)
 (provide 'ui-modeline))

;;; ui-modeline.el ends here
