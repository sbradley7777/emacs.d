;;; python-config.el --- Python Language Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Basic Python editing settings, indentation, and shell configuration.
;;      Supports both python-mode and python-ts-mode with shared configuration.

;;; Code:
(require 'core-constants)
(require 'core-utils)
(require 'python-constants)
(require 'python)
(require 'lang-utils)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 python-setup-common
 ()
 "Common setup for both `python-mode' and python-ts-mode."
 (setq python-indent-guess-indent-offset t)
 (lang-setup-minimal 'python-indent core-tab-width))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Python Shell Integration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Python shell improvements: disable native completion (prevents hangs) and prompt detection warnings (cleaner REPL)
(setq
 python-shell-completion-native-enable
 nil
 python-shell-prompt-detect-failure-warning
 nil
 python-shell-interpreter
 python-default-interpreter)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Mode Hooks - Apply to both python-mode and python-ts-mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(lang-register-dual-mode-hooks python python-setup-common)
(provide 'python-config)
;;; python-config.el ends here
