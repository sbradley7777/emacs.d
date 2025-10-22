;;; eglot-constants.el --- Eglot LSP Configuration Constants -*- lexical-binding: t -*-

;;; Commentary:
;; This file contains constants for Eglot LSP configuration.
;; Constants are prefixed with 'features-eglot-' to avoid naming conflicts.
(require 'core-utils)
(core-utils-with-load-timing
 "eglot-constants.el"
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Eglot Connection Constants
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defconst
  features-eglot-connection-timeout 60
  "Timeout in seconds for Eglot LSP server connections.
Longer timeout accommodates slow remote connections and large codebases where LSP initialization may take time.")

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Eglot Performance Constants
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
Set to t for mode line, 'messages for *Messages* buffer, or nil to disable.")

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Eglot Server Programs Map
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defconst
  features-eglot-lsp-server-map
  '((python-mode . "pylsp")
    (python-ts-mode . "pylsp")
    (c-mode . "clangd")
    (c++-mode . "clangd")
    (c-ts-mode . "clangd")
    (c++-ts-mode . "clangd")
    (bash-ts-mode . "bash-language-server")
    (js-json-mode . "vscode-json-language-server") ; Built-in JSON mode
    (json-ts-mode . "vscode-json-language-server") ; Tree-sitter JSON mode
    (yaml-mode . "yaml-language-server")
    (yaml-ts-mode . "yaml-language-server")
    (toml-mode . "taplo")
    (toml-ts-mode . "taplo")
    (markdown-mode . "marksman")
    (markdown-ts-mode . "marksman"))
  "Map of major modes to their LSP server executables.
Each entry is a cons cell (MODE . EXECUTABLE) where MODE is the major mode symbol
and EXECUTABLE is the LSP server command name.

This map includes both regular and tree-sitter modes for consistency.
Eglot will only activate LSP if the server executable is found in PATH.

Note: Many modes (rust-mode, go-mode, ruby-mode, typescript-mode, etc.) are already
configured in Eglot's built-in eglot-server-programs and don't need to be listed here.
This map is for modes we want to explicitly manage or customize.

Users can extend this in local.el to add support for additional languages:
  (add-to-list 'features-eglot-lsp-server-map '(rust-mode . \"rust-analyzer\"))
  (add-to-list 'features-eglot-lsp-server-map '(go-mode . \"gopls\"))"))
(provide 'eglot-constants)
;;; eglot-constants.el ends here
