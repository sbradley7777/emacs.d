;;; core-logging-constants.el --- Logging Configuration Constants -*- lexical-binding: t -*-

;;; Commentary:
;; This file contains constants for logging and log file management.
;; Constants are prefixed with 'core-' to avoid naming conflicts.
(require 'core-constants)
(require 'core-utils)
(core-utils-with-load-timing
 "core-logging-constants.el"
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Logging Constants
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defconst core-log-max-files 5 "Maximum number of rotated log files to keep.")
 (defconst
  core-log-directory (expand-file-name "log" emacs-local-dir) "Directory for storing log files.")
 (defconst core-messages-log-file "messages.log" "Base name for messages log file."))
(provide 'core-logging-constants)
;;; core-logging-constants.el ends here
