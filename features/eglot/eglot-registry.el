;;; eglot-registry.el --- Eglot LSP Server Registry and Validation -*- lexical-binding: t -*-
;;; Commentary:
;; Registry of Eglot LSP servers with metadata, query functions, and validation.
;; Centralizes all registry-related functionality including:
;; - Type-safe constructor for creating LSP server entries
;; - LSP server registry constant with metadata
;; - Query functions for retrieving server information
;; - Validation functions for server configuration
;; - Strict validation mode options

;;; Code:
(require 'logging-init)
(require 'registry-init)
(require 'registry-query)
(require 'registry-validation)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Registry Constant
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defconst
 eglot-lsp-server-registry
 (list
  (registry-create-entry
   'pylsp
   "Python Language Server Protocol"
   '(python-mode python-ts-mode)
   :binary "pylsp"
   :abbreviation "pylsp-lsp"
   :type 'lsp
   :priority 100
   :url "https://github.com/python-lsp/python-lsp-server"
   :defer-check nil)
  (registry-create-entry
   'clangd
   "C/C++ Language Server"
   '(c-mode c++-mode c-ts-mode c++-ts-mode)
   :binary "clangd"
   :abbreviation "clangd-lsp"
   :type 'lsp
   :priority 100
   :url "https://clangd.llvm.org/"
   :defer-check nil)
  (registry-create-entry
   'vscode-json-languageserver
   "JSON Language Server"
   '(js-json-mode json-ts-mode)
   :binary "vscode-json-languageserver"
   :abbreviation "json-lsp"
   :type 'lsp
   :priority 100
   :url "https://github.com/microsoft/vscode-json-languageserver"
   :defer-check nil)
  (registry-create-entry
   'yaml-language-server
   "YAML Language Server"
   '(yaml-mode yaml-ts-mode)
   :binary "yaml-language-server"
   :abbreviation "yaml-lsp"
   :type 'lsp
   :priority 100
   :url "https://github.com/redhat-developer/yaml-language-server"
   :defer-check nil)
  (registry-create-entry
   'taplo
   "TOML Language Server"
   '(toml-mode toml-ts-mode)
   :binary "taplo"
   :abbreviation "taplo-lsp"
   :type 'lsp
   :priority 100
   :url "https://github.com/tamasfe/taplo"
   :defer-check nil)
  (registry-create-entry
   'marksman
   "Markdown Language Server"
   '(markdown-mode markdown-ts-mode)
   :binary "marksman"
   :abbreviation "markdown-lsp"
   :type 'lsp
   :priority 100
   :url "https://github.com/artempyanykh/marksman"
   :defer-check nil)
  (registry-create-entry
   'bash-language-server
   "Bash Language Server"
   '(sh-mode bash-ts-mode sh-ts-mode)
   :binary "bash-language-server"
   :abbreviation "bash-lsp"
   :type 'lsp
   :priority 100
   :url "https://github.com/bash-lsp/bash-language-server"
   :disabled t
   :disabled-reason "Disabled by default - conflicts with flymake-shellcheck. Enable in local.el if needed."
   :defer-check nil))
 "Registry of Eglot LSP servers using type-safe constructors.

All entries created using `registry-create-entry' for validation.

Format: (IDENTIFIER DESCRIPTION MODES . PROPERTIES)

Where:
- IDENTIFIER: LSP server name as symbol (e.g., \\='pylsp, \\='clangd)
- DESCRIPTION: User-friendly display name (string)
- MODES: List of `major-mode' symbols that use this LSP server
- PROPERTIES: Plist with required and optional properties

Required Properties:
- :binary - LSP server executable name (e.g., \\\"pylsp\\\", \\\"clangd\\\")

Optional Properties:
- :disabled - If t, skip this LSP server in setup
- :disabled-reason - Explanation for disabled servers
- :priority - Integer priority (default 100, lower = higher, 1 = highest)
- :url - Project homepage URL

Example:
  (registry-create-entry
   \\='pylsp \\\"Python Language Server Protocol\\\" \\='(python-mode python-ts-mode)
   :binary \\\"pylsp\\\"
   :priority 100
   :url \\\"https://github.com/python-lsp/python-lsp-server\\\")

This registry uses constructors for type safety and validation at creation time.")


(provide 'eglot-registry)
;;; eglot-registry.el ends here
