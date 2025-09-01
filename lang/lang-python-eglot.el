;;; lang-python-eglot.el --- Python Eglot LSP Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Eglot LSP configuration for Python development.
;;      Provides language server protocol integration for Python using pylsp.

(defvar config-load-start-time (current-time))
(message "Loading lang-python-eglot.el...")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Eglot LSP Python Development Environment
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Simple eglot activation that checks for system-wide pylsp only
(defun python-eglot-maybe-start ()
  "Start eglot for Python only if system-wide pylsp is available."
  (interactive)
  (message "EGLOT: Attempting to start eglot for Python...")
  (if (executable-find "pylsp")
      (progn
        (message "EGLOT: Found pylsp at: %s" (executable-find "pylsp"))
        (condition-case err
            (progn
              (eglot-ensure)
              (message "EGLOT: Successfully started eglot for Python"))
          (error
           (message "EGLOT: Failed to start: %s" (error-message-string err)))))
    (message "EGLOT: pylsp not found - install python-lsp-server for LSP features")))

;; Auto-start eglot for Python files
(add-hook 'python-mode-hook #'python-eglot-maybe-start)

(use-package
 eglot
 :defer t
 :config
 ;; Configure Python LSP server (requires system-wide pylsp: pip3.9 install python-lsp-server)
 (add-to-list 'eglot-server-programs '(python-mode . ("pylsp")))

 ;; Configure pylsp to read pyproject.toml for plugin configuration
 ;; This ensures pylsp uses project-specific linter settings
 (setq eglot-workspace-configuration
       '((pylsp
          (configurationSources . ["pyproject.toml"])
          (plugins
           (mypy
            (enabled . t)
            (live_mode . t)
            (strict . t))
           (ruff
            (enabled . t))
           (pylint
            (enabled . t))))))

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
