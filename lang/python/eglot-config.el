;;; eglot-config.el --- Python Eglot LSP Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Python-specific Eglot LSP configuration.
;;      Provides language server protocol integration for Python using pylsp.
;;      General eglot settings are in features/lsp.el

(require 'core-utils)
(require 'python-constants)

(with-load-timing
 "eglot-config.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Python-Specific Eglot Configuration
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;; Simple eglot activation that uses the configured pylsp path
 (defun
  python-eglot-maybe-start
  ()
  "Start eglot for Python using the configured pylsp server."
  (interactive)
  ;; Only start eglot once per buffer
  (unless
   (bound-and-true-p python-eglot-started)
   (message "ℹ️  EGLOT: Attempting to start eglot for Python...")
   (message "🔧  EGLOT: Using pylsp at: %s" python-eglot-pylsp-path)
   (condition-case err
       (progn
        (eglot-ensure)
        (setq-local python-eglot-started t)
        (message "✅  EGLOT: Successfully started eglot for Python"))
     (error
      (message "❌  EGLOT: Failed to start: %s" (error-message-string err))))))

 ;; Auto-start eglot for Python files
 (add-hook 'python-mode-hook #'python-eglot-maybe-start)

 ;; Python-specific eglot server configuration
 (with-eval-after-load
  'eglot
  ;; Configure Python LSP server using the defined constant path
  (add-to-list 'eglot-server-programs `(python-mode . (,python-eglot-pylsp-path)))

  ;; Use pylsp defaults for all plugins - no configuration overrides
  ;; This provides the cleanest, most maintainable setup
  ;; Python-specific workspace configuration can be added here if needed
  )

 ;; Make this module available for loading with (require 'eglot-config)
 (provide 'eglot-config))
