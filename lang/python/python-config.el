;;; python-config.el --- Python Language Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Basic Python editing settings, indentation, and shell configuration.
;;      Supports both python-mode and python-ts-mode with shared configuration.

;;; Dependencies:
;; - python-constants (for configuration values)
;; - python (built-in Python mode)
;; - core-constants (for core-tab-width)

(require 'python-constants)
(require 'python)

(core-utils-with-load-timing
 "python-config.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Shared Configuration Function
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (defun
  python-setup-common
  ()
  "Common setup for both python-mode and python-ts-mode."
  (setq python-indent-guess-indent-offset t)
  (setq indent-tabs-mode nil)
  (setq python-indent core-tab-width)
  (electric-indent-mode 1))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Python Shell Integration
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;; Python shell improvements: disable native completion (prevents hangs) and prompt detection warnings (cleaner REPL)
 (setq
  python-shell-completion-native-enable
  nil
  python-shell-prompt-detect-failure-warning
  nil
  python-shell-interpreter
  python-default-interpreter)

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Mode Hooks - Apply to both python-mode and python-ts-mode
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;; Apply common setup to python-mode
 (add-hook 'python-mode-hook 'python-setup-common)

 ;; Apply common setup to python-ts-mode (when tree-sitter grammar available)
 (add-hook 'python-ts-mode-hook 'python-setup-common))

(provide 'python-config)

;;; python-config.el ends here
