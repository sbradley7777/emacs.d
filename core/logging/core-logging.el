;;; core-logging.el --- Message Utility Functions -*- lexical-binding: t -*-
;;; Commentary:
;; Lightweight message utility functions with Unicode prefixes.
;; This file has no dependencies to avoid circular dependency issues.
;;; Code:
(require 'subr-x)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Diagnostic formatting constants
(defconst
 logging-diagnostic-date-format "%Y-%m-%d %H:%M:%S"
 "Date format used in diagnostic output.
Format: YYYY-MM-DD HH:MM:SS (e.g., '2025-11-07 11:20:26').")
(defconst
 logging-diagnostic-separator-length 80 "Length of diagnostic section separators in characters.")
(defconst
 logging-diagnostic-closing-separator
 (make-string logging-diagnostic-separator-length ?=)
 "Closing separator for diagnostic sections (80 equals signs).")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Message utility functions with Unicode prefixes
(defun
 logging-success (format-string &rest args)
 "Display success message with ✅ prefix.
FORMAT-STRING is the message format string.
ARGS are the format arguments."
 (apply #'message (concat "✅  " format-string) args))
(defun
 logging-error (format-string &rest args)
 "Display error message with ❌ prefix.
FORMAT-STRING is the message format string.
ARGS are the format arguments."
 (apply #'message (concat "❌  " format-string) args))
(defun
 logging-warning (format-string &rest args)
 "Display warning message with ⚠️ prefix.
FORMAT-STRING is the message format string.
ARGS are the format arguments."
 (apply #'message (concat "⚠️  " format-string) args))
(defun
 logging-info (format-string &rest args)
 "Display info message with ℹ️ prefix.
FORMAT-STRING is the message format string.
ARGS are the format arguments."
 (apply #'message (concat "ℹ️  " format-string) args))
(defun
 logging-loading (format-string &rest args)
 "Display loading message with 🔄 prefix.
FORMAT-STRING is the message format string.
ARGS are the format arguments."
 (apply #'message (concat "🔄  " format-string) args))
(defun
 logging-package (format-string &rest args)
 "Display package message with 📦 prefix.
FORMAT-STRING is the message format string.
ARGS are the format arguments."
 (apply #'message (concat "📦  " format-string) args))
(defun
 logging-config (format-string &rest args)
 "Display config message with ⚙️ prefix.
FORMAT-STRING is the message format string.
ARGS are the format arguments."
 (apply #'message (concat "⚙️  " format-string) args))
(defun
 logging-debug (format-string &rest args)
 "Display debug message with 🛠️ prefix.
FORMAT-STRING is the message format string.
ARGS are the format arguments."
 (apply #'message (concat "🛠️  " format-string) args))
(defun
 logging-theme (format-string &rest args)
 "Display theme message with 🎨 prefix.
FORMAT-STRING is the message format string.
ARGS are the format arguments."
 (apply #'message (concat "🎨  " format-string) args))
(defun
 logging-plain (format-string &rest args)
 "Display plain message without Unicode prefix.
Useful for system diagnostics, debug output, and structured information that doesn't need visual emphasis.
FORMAT-STRING is the message format string.
ARGS are the format arguments."
 (apply #'message format-string args))

(defun
 logging-lang-loaded (language-name modes-and-backend)
 "Display language configuration loaded message with ✅ prefix.
LANGUAGE-NAME is the name of the language (e.g., \\='Python\\=', \\='Bash\\=', \\='C/C++\\=').
MODES-AND-BACKEND is a description of modes and backend configuration.
This follows the standard format: \\='LANGUAGE configuration loaded (MODES-AND-BACKEND)\\='

Examples:
  (logging-lang-loaded \"Python\" \"python-mode and python-ts-mode with pylsp LSP\")
  (logging-lang-loaded \"Bash\" \"sh-mode and bash-ts-mode with flymake-shellcheck\")
  (logging-lang-loaded \"JSON\" \"js-json-mode and json-ts-mode\")"
 (logging-success "%s configuration loaded (%s)" language-name modes-and-backend))

(defun
 logging-batch-skip
 (operation &optional context &rest context-args)
 "Display batch mode skip message with ⏭️  prefix.
OPERATION is the operation being skipped (e.g., \\='package installation\\=', \\='keyring update\\=').
CONTEXT is an optional format string for additional context.
CONTEXT-ARGS are format arguments for CONTEXT.
Format: \\='⏭️  Skipping (batch mode): OPERATION\\=' with optional context appended."
 (if
  context
  (let ((formatted-context (apply #'format context context-args)))
    (message "⏭️  Skipping (batch mode): %s - %s" operation formatted-context))
  (message "⏭️  Skipping (batch mode): %s" operation)))

;; Diagnostic message utilities
(defun
 logging-diagnostic (title lines)
 "Display diagnostic section with TITLE and formatted LINES.
TITLE is the section header text (e.g., \\='Emacs Startup Log\\=' or \\='External Dependencies\\=').
A timestamp is automatically appended to the title in the format (YYYY-MM-DD HH:MM:SS).
LINES is a list of strings to display with 2-space indentation.
Both opening and closing separators are exactly `logging-diagnostic-separator-length' characters.
The entire diagnostic section (separators and content) starts with 2 leading spaces.
Output format:
  <empty line>
    === TITLE (YYYY-MM-DD HH:MM:SS) ========================================== (2 spaces + 80 chars)
    line1
    line2
    ...
    ========================================================================== (2 spaces + 80 chars)
  <empty line>"
 (logging-plain "")
 (let* ((timestamp (format-time-string logging-diagnostic-date-format))
        (title-with-date (format "%s (%s)" title timestamp))
        (prefix "=== ")
        (suffix " ")
        (title-section (concat prefix title-with-date suffix))
        (padding-length (- logging-diagnostic-separator-length (length title-section))))
   (if
    (> padding-length 0)
    (logging-plain "\n  %s%s" title-section (make-string padding-length ?=))
    (logging-plain "\n  %s" title-section)))
 (dolist
  (line lines)
  (if
   (or (string-empty-p line) (string= line " ")) (logging-plain " ") (logging-plain "  %s" line)))
 (logging-plain "  %s\n" logging-diagnostic-closing-separator) (logging-plain ""))

;; Warning buffer integration
(defun
 logging--duplicate-warnings-to-messages (orig-fun type message &optional level buffer-name)
 "Advice to duplicate warning messages to *Messages* buffer.
ORIG-FUN is the original function being advised.
TYPE is the warning type.
MESSAGE is the warning message.
LEVEL is the warning level (optional).
BUFFER-NAME is the target buffer name (optional).
Calls the original `display-warning' function and also logs to *Messages*.
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
(advice-add 'display-warning :around #'logging--duplicate-warnings-to-messages)
(provide 'core-logging)
;;; core-logging.el ends here
