;;; core-utils.el --- Configuration Utilities -*- lexical-binding: t -*-

;;; Commentary:
;; Utility functions and macros for configuration loading and management.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load Timing Utilities
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defmacro
 core-utils-with-load-timing (module-name &rest body)
 "Execute BODY and report loading time for MODULE-NAME.
MODULE-NAME should be a string identifying the module being loaded."
 (declare (indent 1))
 `(let ((start-time (current-time)))
    (message "🔄  Loading %s..." ,module-name)
    ,@body
    (message
     "%s loaded (%.2fs)" ,module-name (float-time (time-subtract (current-time) start-time)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Command Path Utilities
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun
 core-utils-check-command-in-path (command)
 "Check if COMMAND exists in PATH and log message if not found.
Returns t if command is found, nil otherwise."
 (let ((command-path (executable-find command)))
   (if
    command-path
    (progn (message "✅  Command '%s' found at %s" command command-path) t)
    (message "⚠️  Command '%s' not found in PATH" command)
    nil)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Counter Utilities
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defmacro
 core-utils-increment-counter
 (counter-var)
 "Increment COUNTER-VAR and return new value."
 `(setq ,counter-var (1+ ,counter-var)))

;;; Provide this module
(provide 'core-utils)

;;; core-utils.el ends here
