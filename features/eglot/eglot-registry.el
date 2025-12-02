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
(require 'core-logging)
(require 'core-registry)
(require 'core-registry-query)
(require 'core-registry-validation)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Eglot Constructor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(cl-defun
 eglot-registry-create-server
 (identifier description modes &key binary disabled disabled-reason (priority 100) url)
 "Create eglot LSP server registry entry by extending base entry.

Inherits common properties from base constructor:
  :disabled, :disabled-reason, :priority, :url

Eglot-specific required keywords:
  :binary - LSP server executable name (e.g., \\\"pylsp\\\", \\\"clangd\\\")

Example:
  (eglot-registry-create-server
   \\='pylsp \\\"Python Language Server Protocol\\\" \\='(python-mode python-ts-mode)
   :binary \\\"pylsp\\\"
   :priority 100
   :url \\\"https://github.com/python-lsp/python-lsp-server\\\")"
 (unless binary (error "Eglot LSP server %s missing required :binary" identifier))
 (core-registry-create-base-entry
  identifier
  description
  modes
  :binary binary
  :disabled disabled
  :disabled-reason disabled-reason
  :priority priority
  :url url))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Registry Constant
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defconst
 eglot-lsp-server-registry
 (list
  (eglot-registry-create-server
   'pylsp
   "Python Language Server Protocol"
   '(python-mode python-ts-mode)
   :binary "pylsp"
   :priority 100
   :url "https://github.com/python-lsp/python-lsp-server")
  (eglot-registry-create-server
   'clangd
   "C/C++ Language Server"
   '(c-mode c++-mode c-ts-mode c++-ts-mode)
   :binary "clangd"
   :priority 100
   :url "https://clangd.llvm.org/")
  (eglot-registry-create-server
   'vscode-json-languageserver
   "JSON Language Server"
   '(js-json-mode json-ts-mode)
   :binary "vscode-json-languageserver"
   :priority 100
   :url "https://github.com/microsoft/vscode-json-languageserver")
  (eglot-registry-create-server
   'yaml-language-server
   "YAML Language Server"
   '(yaml-mode yaml-ts-mode)
   :binary "yaml-language-server"
   :priority 100
   :url "https://github.com/redhat-developer/yaml-language-server")
  (eglot-registry-create-server
   'taplo
   "TOML Language Server"
   '(toml-mode toml-ts-mode)
   :binary "taplo"
   :priority 100
   :url "https://github.com/tamasfe/taplo")
  (eglot-registry-create-server
   'marksman
   "Markdown Language Server"
   '(markdown-mode markdown-ts-mode)
   :binary "marksman"
   :priority 100
   :url "https://github.com/artempyanykh/marksman")
  (eglot-registry-create-server
   'bash-language-server
   "Bash Language Server"
   '(sh-mode bash-ts-mode sh-ts-mode)
   :binary "bash-language-server"
   :priority 100
   :url "https://github.com/bash-lsp/bash-language-server"
   :disabled t
   :disabled-reason "Disabled by default - conflicts with flymake-shellcheck. Enable in local.el if needed."))
 "Registry of Eglot LSP servers using type-safe constructors.

All entries created using `eglot-registry-create-server' for validation.

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
  (eglot-registry-create-server
   \\='pylsp \\\"Python Language Server Protocol\\\" \\='(python-mode python-ts-mode)
   :binary \\\"pylsp\\\"
   :priority 100
   :url \\\"https://github.com/python-lsp/python-lsp-server\\\")

This registry uses constructors for type safety and validation at creation time.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Customization Variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defcustom
 eglot-strict-validation nil
 "When non-nil, validate registry on load and error if invalid entries found.
This enables strict validation of the `eglot-lsp-server-registry' at load time.
If any registry entry is missing required properties or has invalid values,
an error will be signaled during initialization.

Recommended for development and testing, not for production use."
 :type 'boolean
 :group 'eglot)

(defcustom
 eglot-require-registry-entry nil
 "When non-nil, require all LSP servers to be registered in the registry.
If nil, fall back to heuristic detection for unregistered servers.

When enabled, any LSP server not found in `eglot-lsp-server-registry' will
cause an error instead of falling back to naming convention heuristics.

This is a strict mode option that enforces registry completeness."
 :type 'boolean
 :group 'eglot)

(defcustom
 eglot-strict-mode-checking nil
 "When non-nil, error on mode compatibility mismatches.
If nil, only warn about mismatches (default behavior).

When enabled, using an LSP server in an incompatible major mode will cause
an error instead of just a warning.

This is a strict mode option that prevents invalid configurations."
 :type 'boolean
 :group 'eglot)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Registry Query Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 eglot-registry-find-server (server-symbol)
 "Find LSP server specification in `eglot-lsp-server-registry' for SERVER-SYMBOL.
Returns the server spec entry (SERVER-SYMBOL DESCRIPTION MODES) or nil if not found."
 (core-registry-find-entry eglot-lsp-server-registry server-symbol))

(defun
 eglot-find-server-for-mode (mode)
 "Find first LSP server entry in registry that supports MODE.
Returns the server identifier symbol, or nil if no server supports this mode.
MODE is the major mode symbol to find (e.g., \\='python-mode).

Example:
  (eglot-find-server-for-mode \\='python-mode)
  => pylsp"
 (core-registry-find-by-mode eglot-lsp-server-registry mode))

(defun
 eglot-registry-get-property (server-symbol property)
 "Get PROPERTY for SERVER-SYMBOL from `eglot-lsp-server-registry'.
PROPERTY is a keyword like :binary, :url, or :disabled.
Returns nil if server not found or property not set.

The registry format is (SERVER-SYMBOL DESCRIPTION MODES . PROPERTIES)
where PROPERTIES is a plist starting at index 3."
 (core-registry-get-property eglot-lsp-server-registry server-symbol property))

(defun
 eglot-registry-get-description (server-symbol)
 "Get human-readable description for SERVER-SYMBOL.
Looks up the server in `eglot-lsp-server-registry' and returns its description.
Falls back to the server symbol name if not found in registry."
 (core-registry-get-description eglot-lsp-server-registry server-symbol))

(defun
 eglot-registry-get-binary (server-symbol)
 "Get LSP server binary name for SERVER-SYMBOL from registry.
Returns the :binary property value if set, nil otherwise.
SERVER-SYMBOL is the LSP server identifier symbol to look up."
 (eglot-registry-get-property server-symbol :binary))

(defun
 eglot-registry-get-modes (server-symbol)
 "Get list of supported modes for SERVER-SYMBOL from registry.
Returns list of mode symbols.
SERVER-SYMBOL is the LSP server identifier symbol to look up."
 (core-registry-get-modes eglot-lsp-server-registry server-symbol))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Validation Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 eglot-registry-server-available-p (lsp-server)
 "Return non-nil if LSP-SERVER binary exists and server is not disabled.
LSP-SERVER is the name of the LSP server executable to check for (e.g., \\\"pylsp\\\", \\\"clangd\\\").

This function enforces the :disabled flag from the registry.
Servers marked with :disabled t will return nil, preventing them from being enabled.

This is the standard validation check used before enabling any LSP server.

Note: This function looks up the server by binary name in the registry.
It uses `core-registry-entry-available-p' with is-lsp=t for LSP-specific checking."
 (let ((server-entry
        (cl-find-if
         (lambda
          (entry) (string= (plist-get (nthcdr 3 entry) :binary) lsp-server))
         eglot-lsp-server-registry)))
   (when
    server-entry
    (let ((server-symbol (car server-entry)))
      (core-registry-entry-available-p
       eglot-lsp-server-registry server-symbol lsp-server nil t)))))

(defun
 eglot--mode-compatible-p (supported-modes)
 "Check if current `major-mode' is compatible with SUPPORTED-MODES.
Returns t if current mode matches exactly or derives from any supported mode.

SUPPORTED-MODES is a list of mode symbols from registry entry."
 (core-registry-mode-compatible-p supported-modes major-mode))

(defun
 eglot--validate-registry-entry (entry)
 "Validate a single registry ENTRY for completeness.
Returns nil if valid, error message string if invalid.
Does not signal errors, only returns validation result.

ENTRY is a registry entry in format (SERVER-SYMBOL DESCRIPTION MODES . PROPERTIES)."
 (core-registry-validate-entry entry '(:binary)))

(defun
 eglot--check-mode-compatibility (server-symbol spec)
 "Check mode compatibility for SERVER-SYMBOL using SPEC from registry.
Returns t if compatible or spec is nil.
Logs warning if mode incompatible, or errors if `eglot-strict-mode-checking' is non-nil.

SERVER-SYMBOL is the LSP server identifier symbol.
SPEC is the full registry entry or nil if server not registered."
 (if
  (not spec) t
  (let ((supported-modes (nth 2 spec)))
    (if
     (eglot--mode-compatible-p supported-modes) t
     (let ((msg
            (format
             "LSP server %s not registered for %s (supports: %s)"
             server-symbol
             major-mode
             supported-modes)))
       (if eglot-strict-mode-checking (error "%s" msg) (core-message-warning "%s" msg))
       nil)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Registry Validation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 eglot--validate-registry ()
 "Validate all entries in `eglot-lsp-server-registry' for completeness.
Signals error if any entry is missing required properties or has invalid values.
Uses `eglot--validate-registry-entry' to check each entry.

This function is automatically called at load time when `eglot-strict-validation'
is non-nil."
 (dolist
  (entry eglot-lsp-server-registry)
  (let ((error-msg (eglot--validate-registry-entry entry)))
    (when error-msg (error "%s" error-msg)))))

;; Run registry validation if strict mode enabled
(when eglot-strict-validation (eglot--validate-registry))

(provide 'eglot-registry)
;;; eglot-registry.el ends here
