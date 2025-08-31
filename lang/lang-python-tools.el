;;; lang-python-tools.el --- Python Development Tools Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Python development tools: eglot LSP, flycheck integration, and IDE-like features.
;;      This configuration is extracted from core-packages.el for better organization.

(defvar config-load-start-time (current-time))
(message "Loading lang-python-tools.el...")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Eglot LSP Python Development Environment
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package
 eglot
 :hook (python-mode . eglot-ensure)
 :config
 ;; Dynamically find Python executable for better portability
 (setq python-shell-interpreter (or (executable-find "python3") (executable-find "python") "python3"))

 ;; Configure Python LSP server (requires pylsp: pip install python-lsp-server)
 (add-to-list 'eglot-server-programs '(python-mode . ("pylsp")))

 ;; Configure pylsp to read pyproject.toml for plugin configuration
 ;; This ensures pylsp uses project-specific linter settings
 (setq eglot-workspace-configuration
       '((pylsp (configurationSources . ["pyproject.toml"]))))

 ;; Enable debugging to see LSP communication
 ;; Use M-x eglot-events-buffer to view LSP messages
 ;; Use M-x eglot-stderr-buffer to view server stderr
 (setq eglot-events-buffer-size 200000)  ; Keep more debug messages
 (setq eglot-sync-connect nil)           ; Don't block on connection

 ;; Use flymake as the diagnostic backend (eglot's default)
 ;; Eglot will automatically integrate LSP diagnostics with flymake
 ;; Performance settings are configured in core-packages.el

 ;; Additional Python tools integration for better REPL experience
 (setq python-shell-completion-native-enable nil)) ; Fix completion issues

;; Make this module available for loading with (require 'lang-python-tools)
(provide 'lang-python-tools)
(message "lang-python-tools.el loaded (%.2fs)" (float-time (time-subtract (current-time) config-load-start-time)))
