;;; logging-init.el --- Logging System Loader -*- lexical-binding: t -*-
;;; Commentary:
;; Main entry point for the logging system.
;; Provides a unified interface for all logging operations:
;; - Message formatting utilities (success, error, warning, etc.)
;; - Buffer logging functionality
;; - Table formatting for diagnostics
;; - General logging utilities
;;
;; To use the logging system:
;;   (require 'logging-init)
;;
;; This will load all logging modules automatically.

;;; Code:
(require 'logging-messages)
(require 'logging-buffers)
(require 'core-table-utils)
(require 'logging-utils)

(provide 'logging-init)
;;; logging-init.el ends here
