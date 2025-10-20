;;; core-logging-constants.el --- Logging Configuration Constants -*- lexical-binding: t -*-

;;; Commentary:
;; This file contains constants for logging and log file management.
;; Constants are prefixed with 'core-' to avoid naming conflicts.

(require 'core-constants)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Logging Constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defconst core-log-max-files 5 "Maximum number of rotated log files to keep.")
(defconst
 core-log-directory (expand-file-name "log" emacs-local-dir) "Directory for storing log files.")
(defconst core-messages-log-file "messages.log" "Base name for messages log file.")

;;; Provide this module
(provide 'core-logging-constants)

;;; core-logging-constants.el ends here
