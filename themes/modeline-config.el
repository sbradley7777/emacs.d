;;; modeline-config.el --- Modeline Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Basic modeline configuration using Emacs defaults.
;;      Enables standard modeline features: line/column numbers, time, which-function-mode.
;;      Python venv uses pyvenv's default modeline indicator.

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
 (setq display-time-format "%Y-%m-%d %H:%M") (display-time)

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Modeline Indicators
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;; Configure and enable which-function-mode.
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
 (which-function-mode 1) (provide 'modeline-config))

;;; modeline-config.el ends here
