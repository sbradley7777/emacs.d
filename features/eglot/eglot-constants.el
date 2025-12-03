;;; eglot-constants.el --- Eglot LSP Configuration Constants -*- lexical-binding: t -*-
;;; Commentary:
;; This file contains constants for Eglot LSP configuration.
;; Constants are prefixed with 'eglot-' following parent directory naming convention.

;;; Code:
(require 'core-utils)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defconst
 eglot-connection-timeout 60
 "Timeout in seconds for Eglot LSP server connections.
Longer timeout accommodates slow remote connections and large codebases where LSP initialization may take time.")
(defconst
 eglot-autoshutdown t
 "Automatically shutdown LSP server when last buffer is killed.
Saves system resources when not actively editing files of a particular type.")
(defconst
 eglot-send-changes-idle-time 0.5
 "Delay in seconds before sending buffer changes to LSP server.
Higher values reduce network traffic but increase latency for completions.")
(defconst
 eglot-report-progress 'messages
 "Where to report LSP server progress notifications.
Set to t for mode line, \\='messages for *Messages* buffer, or nil to disable.")
(defconst
 eglot-startup-delay 1.5
 "Delay in seconds before activating eglot after opening a file.
Prevents two issues:
1. \\='Invalid region\\=' flymake warnings when LSP sends diagnostics before buffer is loaded
2. Allows git-sync to complete before eglot starts (git-sync takes ~0.7s typically)
The timer fires after this fixed delay regardless of idle state, ensuring eglot starts
after both buffer initialization and git-sync operations complete.")
(provide 'eglot-constants)
;;; eglot-constants.el ends here
