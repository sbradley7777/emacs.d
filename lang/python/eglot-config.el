;;; eglot-config.el --- Python Eglot LSP Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Python-specific Eglot LSP configuration.
;;      Provides language server protocol integration for Python using pylsp.
;;      General eglot settings are in features/lsp.el

(require 'core-utils)
(require 'python-constants)

(with-load-timing
 "eglot-config.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Python Eglot Configuration with TRAMP Support
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (defun
  eglot-configure-server
  ()
  "Configure eglot server with TRAMP support."
  (require 'python-core)
  ;; Remove existing python-mode configuration
  (setq eglot-server-programs (assq-delete-all 'python-mode eglot-server-programs))
  ;; Add enhanced configuration using the new server contact function
  (add-to-list 'eglot-server-programs `(python-mode . eglot-server-contact))
  (message "✅ Enhanced Python eglot server configuration activated"))

 (defun
  eglot-apply-remote-settings
  ()
  "Apply enhanced settings for remote eglot connections."
  (require 'python-constants)
  (setq eglot-connect-timeout eglot-connect-timeout)
  (setq eglot-sync-connect eglot-sync-connect)
  (setq eglot-send-changes-idle-time eglot-send-changes-idle-time)
  (message "✅ Enhanced eglot remote settings applied"))

 ;; Activate enhanced configuration after eglot loads
 (with-eval-after-load 'eglot (eglot-configure-server) (eglot-apply-remote-settings))

 ;; Make this module available for loading with (require 'eglot-config)
 (provide 'eglot-config))
