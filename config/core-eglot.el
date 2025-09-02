;;; core-eglot.el --- General Eglot LSP Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      General Eglot configuration that applies to all languages.
;;      Language-specific server configurations should be in lang/lang-<language>-eglot.el files.

(defvar config-load-start-time (current-time))
(message "Loading core-eglot.el...")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; General Eglot LSP Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package
 eglot
 :defer t
 :config
 ;; Performance and stability settings that apply to all language servers
 ;; Note: eglot-events-buffer-size is set to 0 in core-packages.el for performance
 ;; Use M-x eglot-events-buffer to view LSP messages (when enabled)
 ;; Use M-x eglot-stderr-buffer to view server stderr
 ;; Temporarily enable debugging: (setq eglot-events-buffer-size 200000)
 (setq eglot-sync-connect nil) ; Don't block on connection
 (setq eglot-autoshutdown t) ; Auto-shutdown when last buffer closed
 (setq eglot-send-changes-idle-time 0.5) ; Reduce change notification frequency

 ;; Use flymake as the diagnostic backend (eglot's default)
 ;; Eglot will automatically integrate LSP diagnostics with flymake
 ;; Flymake display configuration is in core-flymake.el
 )

;; Make this module available for loading with (require 'core-eglot)
(provide 'core-eglot)
(message
 "core-eglot.el loaded (%.2fs)"
 (float-time (time-subtract (current-time) config-load-start-time)))
