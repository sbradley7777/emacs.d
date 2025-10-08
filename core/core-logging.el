;;; core-logging.el --- Message Utility Functions -*- lexical-binding: t -*-

;;; Commentary:
;; Lightweight message utility functions with Unicode prefixes.
;; This file has no dependencies to avoid circular dependency issues.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Message Utility Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun
 core-message-success
 (format-string &rest args)
 "Display success message with ✅ prefix."
 (apply #'message (concat "✅  " format-string) args))

(defun
 core-message-error
 (format-string &rest args)
 "Display error message with ❌ prefix."
 (apply #'message (concat "❌  " format-string) args))

(defun
 core-message-warning
 (format-string &rest args)
 "Display warning message with ⚠️ prefix."
 (apply #'message (concat "⚠️  " format-string) args))

(defun
 core-message-info
 (format-string &rest args)
 "Display info message with ℹ️ prefix."
 (apply #'message (concat "ℹ️  " format-string) args))

(defun
 core-message-loading
 (format-string &rest args)
 "Display loading message with 🔄 prefix."
 (apply #'message (concat "🔄  " format-string) args))

(defun
 core-message-package
 (format-string &rest args)
 "Display package message with 📦 prefix."
 (apply #'message (concat "📦  " format-string) args))

(defun
 core-message-config
 (format-string &rest args)
 "Display config message with ⚙️ prefix."
 (apply #'message (concat "⚙️  " format-string) args))

(defun
 core-message-debug
 (format-string &rest args)
 "Display debug message with 🛠️ prefix."
 (apply #'message (concat "🛠️  " format-string) args))

(defun
 core-message-theme
 (format-string &rest args)
 "Display theme message with 🎨 prefix."
 (apply #'message (concat "🎨  " format-string) args))

(defun
 core-message-plain (format-string &rest args)
 "Display plain message without Unicode prefix.
Useful for system diagnostics, debug output, and structured information that doesn't need visual emphasis."
 (apply #'message format-string args))

(provide 'core-logging)

;;; core-logging.el ends here
