;;; modeline-config.el --- Modeline Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Modeline customization and status indicators.
;;      Consolidates all modeline-related configuration for global modeline display.
;;      Note: Buffer-specific modelines (treemacs, imenu-list) are configured in their respective modules.

(require 'modeline-utils)

(core-utils-with-load-timing
 "modeline-config.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Basic Modeline Settings
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Enable column number display in modeline
 (column-number-mode 1)

 ;; Enable line number display in modeline
 (line-number-mode 1)

 ;; Enable buffer size indication in modeline
 (size-indication-mode 1)

 ;; Display the time in modeline with custom format (YYYY-MM-dd HH:MM)
 (setq display-time-format "  %Y-%m-%d %H:%M") ; Leading spaces for separation
 (display-time)

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Modeline Indicators
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Note: add-to-list adds to beginning, so add in reverse order of desired display
 ;; Desired order: Python venv → Function name → username@hostname → time

 ;; Add system information indicator (username@hostname) - added first, appears before time
 (modeline-add-system-info-indicator)

 ;; Configure and enable which-function-mode (adds function name before username@hostname)
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
 (which-function-mode 1)

 ;; Add Python virtual environment indicator - added last, appears first (leftmost)
 (modeline-add-python-venv-indicator)

 (provide 'modeline-config))

;;; modeline-config.el ends here
