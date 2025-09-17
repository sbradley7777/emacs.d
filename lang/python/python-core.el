;;; python-core.el --- Core Python Language Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Basic Python editing settings, indentation, and shell configuration.

(require 'core-constants)
(require 'core-utils)
(require 'python-constants)
(require 'python-utils)

(with-load-timing
 "python-core.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Python-specific indentation settings
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (add-hook
  'python-mode-hook
  (lambda
   () "Configure Python mode with project-specific indentation settings."
   (setq python-indent-guess-indent-offset t) ; Attempts to guess indentation offset based on existing file indentation
   (setq indent-tabs-mode nil) ; Use spaces
   (setq python-indent core-tab-width) ; Use standard tab width for indentation
   (electric-indent-mode 1) ; Enable electric indentation for automatic formatting
   ;; Enable eglot-powered imenu when eglot is active
   (when
    (and (featurep 'eglot) (eglot-managed-p))
    (setq imenu-create-index-function 'eglot-imenu)))) ; Use LSP symbol information for better navigation

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Eglot LSP Integration
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (defun
  eglot-ensure-python
  ()
  "Ensure eglot is started for Python files, independent of virtual environment status."
  (condition-case err
      (progn (eglot-ensure) (message "✅ EGLOT: Started for %s" (buffer-name)))
    (error
     (message "❌ EGLOT: Failed to start for %s: %s" (buffer-name) (error-message-string err)))))

 (defun
  eglot-server-contact
  (&optional interactive)
  "Server contact function using unified pylsp detection."
  (require 'tramp-utils)

  (let ((result (eglot-find-pylsp)))
    (if
     (file-remote-p default-directory)
     (let ((user (file-remote-p default-directory 'user))
           (host (file-remote-p default-directory 'host))
           (path (car result)))
       (message
        "🔧 EGLOT: Server contact (remote) for %s: %s@%s:%s" (buffer-file-name) user host path))
     (let ((user (user-login-name))
           (host (system-name))
           (path (car result)))
       (message
        "🔧 EGLOT: Server contact (local) for %s: %s@%s:%s" (buffer-file-name) user host path)))
    result))

 ;; Add eglot activation to python-mode-hook (independent of pyvenv)
 (add-hook 'python-mode-hook #'eglot-ensure-python)

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Python shell integration improvements
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Python shell improvements: disable native completion (prevents hangs) and prompt detection warnings (cleaner REPL)
 (setq python-shell-completion-native-enable nil python-shell-prompt-detect-failure-warning nil))

;; Make this module available for loading with (require 'core)
(provide 'python-core)
