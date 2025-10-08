;;; python-core.el --- Core Python Language Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Basic Python editing settings, indentation, and shell configuration.

;;; Dependencies:
;; - python-constants (for configuration values)
;; - python-utils (for utility functions)
;; - python (built-in Python mode)
;; - core-constants (for core-tab-width)

(require 'python-constants)
(require 'python-utils)
(require 'python)

(core-utils-with-load-timing
 "python-core.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Python-specific indentation settings
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (add-hook
  'python-mode-hook
  (lambda
   () "Configure Python mode with project-specific indentation settings."
   (setq python-indent-guess-indent-offset t) ; Attempts to guess indentation offset based on existing file indentation
   (setq indent-tabs-mode nil) ; Use spaces
   (setq python-indent core-tab-width) ; Use standard tab width for indentation
   (electric-indent-mode 1))) ; Enable electric indentation for automatic formatting

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Python shell integration improvements
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Python shell improvements: disable native completion (prevents hangs) and prompt detection warnings (cleaner REPL)
 (setq
  python-shell-completion-native-enable
  nil
  python-shell-prompt-detect-failure-warning
  nil
  python-shell-interpreter
  python-default-interpreter))

;; Make this module available for loading with (require 'core)
(provide 'python-core)
