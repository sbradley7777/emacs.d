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

 ;; Performance optimizations
 (setq eglot-events-buffer-size 0) ; Disable event logging for performance
 (setq eglot-sync-connect nil) ; Async connection

 ;; Integration with flycheck - let eglot handle diagnostics but allow flycheck for additional checks
 (setq eglot-stay-out-of '(flycheck))

 ;; Use flycheck for additional linting beyond LSP diagnostics
 (when (require 'flycheck nil t)
   (add-hook 'python-mode-hook 'flycheck-mode)
   (flycheck-add-next-checker 'python-flake8 'python-pylint))

 ;; Additional Python tools integration for better REPL experience
 (setq python-shell-completion-native-enable nil)) ; Fix completion issues

;; Make this module available for loading with (require 'lang-python-tools)
(provide 'lang-python-tools)
(message "lang-python-tools.el loaded (%.2fs)" (float-time (time-subtract (current-time) config-load-start-time)))
