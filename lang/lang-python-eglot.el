;;; lang-python-eglot.el --- Python Eglot LSP Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Eglot LSP configuration for Python development.
;;      Provides language server protocol integration for Python using pylsp.

(defvar config-load-start-time (current-time))
(message "Loading lang-python-eglot.el...")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Eglot LSP Python Development Environment
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package
 eglot
 :hook (python-mode . eglot-ensure)
 :config
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
 )

;; Make this module available for loading with (require 'lang-python-eglot)
(provide 'lang-python-eglot)
(message "lang-python-eglot.el loaded (%.2fs)" (float-time (time-subtract (current-time) config-load-start-time)))
