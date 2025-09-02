;;; lang-python-eglot.el --- Python Eglot LSP Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Python-specific Eglot LSP configuration.
;;      Provides language server protocol integration for Python using pylsp.
;;      General eglot settings are in config/core-eglot.el

(defvar config-load-start-time (current-time))
(message "Loading lang-python-eglot.el...")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Python-Specific Eglot Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Simple eglot activation that checks for system-wide pylsp only
(defun
 python-eglot-maybe-start
 ()
 "Start eglot for Python only if system-wide pylsp is available."
 (interactive)
 (message "EGLOT: Attempting to start eglot for Python...")
 (if
  (executable-find "pylsp")
  (progn
   (message "EGLOT: Found pylsp at: %s" (executable-find "pylsp"))
   (condition-case err
       (progn
         (require 'eglot) ; Ensure eglot is loaded before using it
         (eglot-ensure)
         (message "EGLOT: Successfully started eglot for Python"))
     (error
      (message "EGLOT: Failed to start: %s" (error-message-string err)))))
  (message "EGLOT: pylsp not found - install python-lsp-server for LSP features")))

;; Auto-start eglot for Python files
(add-hook 'python-mode-hook #'python-eglot-maybe-start)

;; Python-specific eglot server configuration
(with-eval-after-load 'eglot
  ;; Configure Python LSP server (requires system-wide pylsp: pip3.9 install python-lsp-server)
  (add-to-list 'eglot-server-programs '(python-mode . ("pylsp")))

  ;; Use pylsp defaults for all plugins - no configuration overrides
  ;; This provides the cleanest, most maintainable setup
  ;; Python-specific workspace configuration can be added here if needed
  )

;; Make this module available for loading with (require 'lang-python-eglot)
(provide 'eglot-config)
(message
 "lang-python-eglot.el loaded (%.2fs)"
 (float-time (time-subtract (current-time) config-load-start-time)))
