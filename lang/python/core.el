;;; core.el --- Core Python Language Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Basic Python editing settings, indentation, and shell configuration.

(require 'core-constants)

(defvar config-load-start-time (current-time))
(message "🔄  Loading core.el...")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Python-specific indentation settings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-hook
 'python-mode-hook
 (lambda
  () "Configure Python mode with project-specific indentation settings."
  (setq python-indent-guess-indent-offset t) ; Attempts to guess indentation offset based on existing file indentation
  (setq indent-tabs-mode nil) ; Use spaces
  (setq python-indent core-tab-width))) ; Use standard tab width for indentation

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Python shell integration improvements
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Python shell improvements: disable native completion (prevents hangs) and prompt detection warnings (cleaner REPL)
(setq python-shell-completion-native-enable nil python-shell-prompt-detect-failure-warning nil)

;; Make this module available for loading with (require 'core)
(provide 'core)
(message
 "core.el loaded (%.2fs)" (float-time (time-subtract (current-time) config-load-start-time)))
