;;; tools.el --- Python Environment and REPL Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Basic Python environment setup: interpreter detection and REPL configuration.

(defvar config-load-start-time (current-time))
(message "🔄  Loading tools.el...")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Python Environment and Tools Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Dynamically find Python executable for better portability
(setq
 python-shell-interpreter (or (executable-find "python3") (executable-find "python") "python3"))

;; Note: Native completion disabled in core.el to prevent REPL hangs

;; Make this module available for loading with (require 'tools)
(provide 'tools)
(message
 "tools.el loaded (%.2fs)" (float-time (time-subtract (current-time) config-load-start-time)))
