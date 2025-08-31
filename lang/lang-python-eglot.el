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
 :hook (python-mode . python-eglot-maybe-start)
 :config
 ;; Configure Python LSP server (requires pylsp: pip install python-lsp-server)
 (add-to-list 'eglot-server-programs '(python-mode . ("pylsp")))

 ;; Smart eglot activation that checks for pylsp availability
 (defun python-eglot-maybe-start ()
   "Start eglot for Python only if pylsp is available."
   (interactive)
   (if (or (executable-find "pylsp")
           (and (boundp 'pyvenv-virtual-env)
                pyvenv-virtual-env
                (file-executable-p (expand-file-name "bin/pylsp" pyvenv-virtual-env))))
       (condition-case err
           (eglot-ensure)
         (error
          (message "Eglot failed to start: %s" (error-message-string err))))
     (message "pylsp not found - install python-lsp-server for LSP features")))

 ;; Configure pylsp to read pyproject.toml for plugin configuration
 ;; This ensures pylsp uses project-specific linter settings
 (setq eglot-workspace-configuration
       '((pylsp (configurationSources . ["pyproject.toml"]))))

 ;; Performance and stability settings
 ;; Note: eglot-events-buffer-size is set to 0 in core-packages.el for performance
 ;; Use M-x eglot-events-buffer to view LSP messages (when enabled)
 ;; Use M-x eglot-stderr-buffer to view server stderr
 ;; Temporarily enable debugging: (setq eglot-events-buffer-size 200000)
 (setq eglot-sync-connect nil)           ; Don't block on connection
 (setq eglot-autoshutdown t)             ; Auto-shutdown when last buffer closed
 (setq eglot-send-changes-idle-time 0.5) ; Reduce change notification frequency

 ;; Use flymake as the diagnostic backend (eglot's default)
 ;; Eglot will automatically integrate LSP diagnostics with flymake
 ;; Performance settings are configured in core-packages.el
 )

;; Make this module available for loading with (require 'lang-python-eglot)
(provide 'lang-python-eglot)
(message "lang-python-eglot.el loaded (%.2fs)" (float-time (time-subtract (current-time) config-load-start-time)))
