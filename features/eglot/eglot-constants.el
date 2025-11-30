;;; eglot-constants.el --- Eglot LSP Configuration Constants -*- lexical-binding: t -*-
;;; Commentary:
;; This file contains constants for Eglot LSP configuration.
;; Constants are prefixed with 'features-eglot-' to avoid naming conflicts.

;;; Code:
(require 'core-utils)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defconst
 features-eglot-connection-timeout 60
 "Timeout in seconds for Eglot LSP server connections.
Longer timeout accommodates slow remote connections and large codebases where LSP initialization may take time.")
(defconst
 features-eglot-autoshutdown t
 "Automatically shutdown LSP server when last buffer is killed.
Saves system resources when not actively editing files of a particular type.")
(defconst
 features-eglot-send-changes-idle-time 0.5
 "Delay in seconds before sending buffer changes to LSP server.
Higher values reduce network traffic but increase latency for completions.")
(defconst
 features-eglot-report-progress 'messages
 "Where to report LSP server progress notifications.
Set to t for mode line, \\='messages for *Messages* buffer, or nil to disable.")
(defconst
 features-eglot-startup-delay 1.5
 "Delay in seconds before activating eglot after opening a file.
Prevents two issues:
1. \\='Invalid region\\=' flymake warnings when LSP sends diagnostics before buffer is loaded
2. Allows git-sync to complete before eglot starts (git-sync takes ~0.7s typically)
The timer fires after this fixed delay regardless of idle state, ensuring eglot starts
after both buffer initialization and git-sync operations complete.")
(provide 'eglot-constants)
;;; eglot-constants.el ends here
