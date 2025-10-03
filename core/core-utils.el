;;; core-utils.el --- Configuration Utilities -*- lexical-binding: t -*-

;;; Commentary:
;; Utility functions and macros for configuration loading and management.

(require 'logging)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load Timing Utilities
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defmacro
 core-utils-with-load-timing (module-name &rest body)
 "Execute BODY and report loading time for MODULE-NAME.
MODULE-NAME should be a string identifying the module being loaded."
 (declare (indent 1))
 `(let ((start-time (current-time)))
    (core-message-loading "Loading %s..." ,module-name)
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
    (progn
     (core-message-success
      "The LSP command \"%s\" was found in PATH at %s on host (local): %s"
      command
      command-path
      (system-name))
     t)
    (core-message-warning
     "The LSP command \"%s\" was not found in PATH on host (local): %s" command (system-name))
    nil)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Counter Utilities
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defmacro
 core-utils-increment-counter
 (counter-var)
 "Increment COUNTER-VAR and return new value."
 `(setq ,counter-var (1+ ,counter-var)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Directory Management Utilities
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun
 core-utils-ensure-directory (dir-path)
 "Ensure DIR-PATH exists, creating it if necessary.
Returns t if directory exists/was created, nil if creation failed."
 (let ((expanded-path (expand-file-name dir-path)))
   (if
    (file-exists-p expanded-path)
    t ; Directory already exists
    (condition-case err
        (progn
         (make-directory expanded-path t)
         (core-message-package "Created directory: %s" expanded-path)
         t)
      (error
       (core-message-error
        "Failed to create directory %s: %s" expanded-path (error-message-string err))
       nil)))))

;;; Provide this module
(provide 'core-utils)

;;; core-utils.el ends here
