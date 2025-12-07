;;; flymake-registry.el --- Flymake Backend Registry and Validation -*- lexical-binding: t -*-
;;; Commentary:
;; Registry of Flymake backends with metadata, query functions, and validation.
;; Centralizes all registry-related functionality including:
;; - Type-safe constructor for creating backend entries
;; - Backend registry constant with metadata
;; - Query functions for retrieving backend information
;; - Validation functions for backend configuration
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
 flymake-backend-registry
 (list
  (registry-create-entry
   'flymake-aspell--check
   "Aspell spell checking"
   '(text-mode prog-mode)
   :abbreviation "f-a--"
   :type 'direct
   :binary "aspell"
   :priority 100
   :url "https://github.com/GNUAspell/aspell"
   :defer-check nil)
  (registry-create-entry
   'python-flymake
   "Python built-in"
   '(python-mode python-ts-mode)
   :abbreviation "p-f"
   :type 'direct
   :binary "(built-in)"
   :priority 100
   :url "https://docs.python.org/3/library/pydoc.html"
   :defer-check t)
  (registry-create-entry
   'elisp-flymake-byte-compile
   "Elisp Byte Compile"
   '(emacs-lisp-mode lisp-interaction-mode)
   :abbreviation "e-f-b-c"
   :type 'direct
   :binary "(built-in)"
   :priority 100
   :url "https://www.gnu.org/software/emacs/manual/html_node/elisp/Byte-Compilation.html"
   :defer-check nil)
  (registry-create-entry
   'elisp-flymake-checkdoc
   "Elisp Checkdoc"
   '(emacs-lisp-mode lisp-interaction-mode)
   :abbreviation "e-f-c"
   :type 'direct
   :binary "(built-in)"
   :priority 100
   :url "https://www.gnu.org/software/emacs/manual/html_node/elisp/Documentation-Tips.html"
   :defer-check nil)
  (registry-create-entry
   'flymake-shellcheck-load
   "ShellCheck linter (loader)"
   '(sh-mode sh-ts-mode bash-ts-mode)
   :abbreviation "f-s-l"
   :type 'loader-based
   :binary "shellcheck"
   :priority 100
   :url "https://github.com/federicotdn/flymake-shellcheck"
   :defer-check nil)
  (registry-create-entry
   'flymake-shellcheck--backend
   "ShellCheck linter (backend)"
   '(sh-mode sh-ts-mode bash-ts-mode)
   :abbreviation "f-s--"
   :type 'direct
   :binary "shellcheck"
   :priority 100
   :url "https://github.com/federicotdn/flymake-shellcheck"
   :defer-check nil)
  (registry-create-entry
   'sh-shellcheck-flymake
   "ShellCheck built-in"
   '(sh-mode sh-ts-mode bash-ts-mode)
   :abbreviation "s-s-f"
   :type 'direct
   :binary "shellcheck"
   :priority 100
   :url "https://github.com/koalaman/shellcheck"
   :disabled t
   :disabled-reason "Requires ShellCheck 0.7.0+ for --format=json1 support. Current system has 0.6.0. See: https://github.com/sbradley7777/emacs.d/issues/48"
   :defer-check nil)
  (registry-create-entry
   'flymake-collection-yamllint
   "YAMLLint"
   '(yaml-mode yaml-ts-mode)
   :abbreviation "f-c-y"
   :type 'direct
   :binary "yamllint"
   :priority 100
   :url "https://github.com/adrienverge/yamllint"
   :defer-check t)
  (registry-create-entry
   'flymake-collection-jsonlint
   "JSONLint"
   '(js-json-mode json-ts-mode)
   :abbreviation "f-c-j"
   :type 'direct
   :binary "jsonlint"
   :priority 100
   :url "https://github.com/zaach/jsonlint"
   :defer-check t)
  (registry-create-entry
   'flymake-collection-markdownlint
   "MarkdownLint"
   '(markdown-mode markdown-ts-mode)
   :abbreviation "f-c-m"
   :type 'direct
   :binary "markdownlint"
   :priority 100
   :url "https://github.com/DavidAnson/markdownlint"
   :defer-check t)
  (registry-create-entry
   'eglot-flymake-backend
   "Eglot LSP"
   '(multiple)
   :abbreviation "e-f-b"
   :type 'lsp
   :priority 100
   :url "https://github.com/joaotavora/eglot"
   :defer-check nil))
 "Registry of Flymake backends using type-safe constructors.

All entries created using `registry-create-entry' for validation.

Format: (FUNCTION-SYMBOL DESCRIPTION MODES . PROPERTIES)

Where:
- FUNCTION-SYMBOL: Backend function name (symbol)
- DESCRIPTION: User-friendly display name (string)
- MODES: List of `major-mode' symbols or (multiple)
- PROPERTIES: Plist with required and optional properties

Required Properties:
- :abbreviation     - Short identifier used in diagnostics (e.g., \"f-c-y\")
- :type             - Backend type: \\='direct, \\='loader-based, or \\='lsp

Optional Properties:
- :binary           - Expected binary name (e.g., \"yamllint\")
- :loader           - Function symbol to call for loading this backend
- :disabled         - If t, skip this backend in setup
- :disabled-reason  - Explanation for disabled backends
- :priority         - Integer priority (default 100, lower = higher, 1 = highest)
- :url              - Project homepage URL
- :defer-check      - If t, defer initial check until LSP connects (dual-backend timing control)

Example:
  (registry-create-entry
   \\='flymake-collection-yamllint \"YAMLLint\" \\='(yaml-mode yaml-ts-mode)
   :abbreviation \"f-c-y\"
   :type \\='direct
   :binary \"yamllint\"
   :priority 100
   :url \"https://github.com/adrienverge/yamllint\")

This registry uses constructors for type safety and validation at creation time.")

(defun
 flymake-remove-disabled-backends ()
 "Remove all disabled backends from `flymake-diagnostic-functions'.
This enforces the :disabled flag by removing backends that are marked as
disabled in the registry but were added by external code (e.g., built-in modes).

This function is called automatically via `flymake-mode-hook' to ensure
disabled backends never run, even if added by Emacs built-in modes."
 (when
  (and (boundp 'flymake-diagnostic-functions) flymake-diagnostic-functions)
  (setq
   flymake-diagnostic-functions
   (registry-filter-disabled flymake-backend-registry flymake-diagnostic-functions))))


(provide 'flymake-registry)
;;; flymake-registry.el ends here
