;;; python-config.el --- Python Language Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Basic Python editing settings, indentation, and shell configuration.
;;      Supports both python-mode and python-ts-mode with shared configuration.
;;      Uses pylsp LSP server for diagnostics (including ruff linting via python-lsp-ruff plugin).

;;; Code:
(require 'core-constants)
(require 'core-utils)
(require 'logging-init)
(require 'python-constants)
(require 'python)
(require 'lang-utils)
(require 'flymake-lang-setup)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 python-setup-common
 ()
 "Common setup for both `python-mode' and python-ts-mode."
 (setq python-indent-guess-indent-offset t)
 (lang-setup-minimal 'python-indent core-tab-width)
 (flymake-lang-setup-lsp-backend))

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

(logging-lang-loaded "Python" "python-mode and python-ts-mode with pylsp LSP")
(provide 'python-config)
;;; python-config.el ends here
