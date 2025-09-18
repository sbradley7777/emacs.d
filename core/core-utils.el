;;; core-utils.el --- Configuration Utilities -*- lexical-binding: t -*-

;;; Commentary:
;; Utility functions and macros for configuration loading and management.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load Timing Utilities
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

;;; Provide this module
(provide 'core-utils)

;;; core-utils.el ends here
