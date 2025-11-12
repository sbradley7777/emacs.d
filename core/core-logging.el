;;; core-logging.el --- Message Utility Functions -*- lexical-binding: t -*-
;;; Commentary:
;; Lightweight message utility functions with Unicode prefixes.
;; This file has no dependencies to avoid circular dependency issues.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Message Utility Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Code:
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Diagnostic Message Utilities
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defconst
 core-diagnostic-date-format "%Y-%m-%d %H:%M:%S"
 "Date format used in diagnostic output.
Format: YYYY-MM-DD HH:MM:SS (e.g., '2025-11-07 11:20:26').")
(defconst
 core-diagnostic-separator-length 80 "Length of diagnostic section separators in characters.")
(defconst
 core-diagnostic-closing-separator
 (make-string core-diagnostic-separator-length ?=)
 "Closing separator for diagnostic sections (80 equals signs).")
(defun
 core-message-diagnostic (title lines)
 "Display diagnostic section with TITLE and formatted LINES.
TITLE is the section header text (e.g., 'Emacs Startup Log' or 'External Dependencies').
A timestamp is automatically appended to the title in the format (YYYY-MM-DD HH:MM:SS).
LINES is a list of strings to display with 2-space indentation.
Both opening and closing separators are exactly `core-diagnostic-separator-length' characters.
The entire diagnostic section (separators and content) starts with 2 leading spaces.
Output format:
  <empty line>
    === TITLE (YYYY-MM-DD HH:MM:SS) ========================================== (2 spaces + 80 chars)
    line1
    line2
    ...
    ========================================================================== (2 spaces + 80 chars)
  <empty line>"
 (core-message-plain "")
 (let* ((timestamp (format-time-string core-diagnostic-date-format))
        (title-with-date (format "%s (%s)" title timestamp))
        (prefix "=== ")
        (suffix " ")
        (title-section (concat prefix title-with-date suffix))
        (padding-length (- core-diagnostic-separator-length (length title-section))))
   (if
    (> padding-length 0)
    (core-message-plain "\n  %s%s" title-section (make-string padding-length ?=))
    (core-message-plain "\n  %s" title-section)))
 (dolist
  (line lines)
  (if
   (or (string-empty-p line) (string= line " "))
   (core-message-plain " ")
   (core-message-plain "  %s" line)))
 (core-message-plain "  %s\n" core-diagnostic-closing-separator) (core-message-plain ""))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Warning Buffer Integration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 core-logging-duplicate-warnings-to-messages (orig-fun type message &optional level buffer-name)
 "Advice to duplicate warning messages to *Messages* buffer.
Calls the original display-warning function and also logs to *Messages*.
Filters out :debug level warnings to reduce noise."
 (prog1
  (apply orig-fun type message level buffer-name nil)
  ;; Also log to *Messages* buffer with formatted prefix (skip debug messages)
  (unless
   (eq level :debug)
   (let ((type-str
          (cond
           ((symbolp type)
            (symbol-name type))
           ((listp type)
            (format "%s" (car type)))
           (t
            (format "%s" type))))
         (level-str
          (cond
           ((symbolp level)
            (symbol-name level))
           ((listp level)
            (format "%s" (car level)))
           (level
            (format "%s" level))
           (t
            "WARNING"))))
     (message "[%s] %s: %s" (upcase type-str) (upcase level-str) message)))))

;; Add advice to display-warning to duplicate warnings to *Messages* buffer
(advice-add 'display-warning :around #'core-logging-duplicate-warnings-to-messages)
(provide 'core-logging)
;;; core-logging.el ends here
