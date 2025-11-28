;;; flymake-constants.el --- Flymake Configuration Constants -*- lexical-binding: t -*-
;;; Commentary:
;; This file contains constants for Flymake backend configuration and diagnostics display.
;; Constants define the known backends, their descriptions, and display name mappings.

;;; Code:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defconst
 flymake-backend-registry
 '((flymake-aspell--check
    "Aspell spell checking"
    (text-mode prog-mode)
    :abbreviation "f-a--"
    :type direct)
   (python-flymake "Python built-in" (python-mode python-ts-mode) :abbreviation "p-f" :type direct)
   (elisp-flymake-byte-compile
    "Elisp Byte Compile"
    (emacs-lisp-mode lisp-interaction-mode)
    :abbreviation "e-f-b-c"
    :type direct)
   (elisp-flymake-checkdoc
    "Elisp Checkdoc"
    (emacs-lisp-mode lisp-interaction-mode)
    :abbreviation "e-f-c"
    :type direct)
   (flymake-shellcheck--backend
    "ShellCheck linter"
    (sh-mode sh-ts-mode bash-ts-mode)
    :abbreviation "f-s--"
    :loader flymake-shellcheck-load
    :type loader-based
    :binary "shellcheck")
   (sh-shellcheck-flymake
    "ShellCheck built-in"
    (sh-mode sh-ts-mode bash-ts-mode)
    :abbreviation "s-s-f"
    :type direct
    :binary "shellcheck")
   (flymake-collection-yamllint
    "YAMLLint"
    (yaml-mode yaml-ts-mode)
    :abbreviation "f-c-y"
    :type direct
    :binary "yamllint")
   (flymake-collection-jsonlint
    "JSONLint"
    (js-json-mode json-ts-mode)
    :abbreviation "f-c-j"
    :type direct
    :binary "jsonlint")
   (flymake-collection-markdownlint
    "MarkdownLint"
    (markdown-mode markdown-ts-mode)
    :abbreviation "f-c-m"
    :type direct
    :binary "markdownlint")
   (eglot-flymake-backend "Eglot LSP" (multiple) :abbreviation "e-f-b" :type lsp))
 "Registry of Flymake backends with metadata and configuration.

Format: (FUNCTION-SYMBOL DESCRIPTION MODES . PROPERTIES)

Where:
- FUNCTION-SYMBOL: Backend function name (symbol)
- DESCRIPTION: User-friendly display name (string)
- MODES: List of `major-mode' symbols or (multiple)
- PROPERTIES: Plist with :abbreviation, :loader, :type

Properties:
- :abbreviation - Short identifier used in diagnostics buffer (e.g., \\='e-f-b\\=')
- :loader - Function symbol to call for loading this backend (optional)
- :type - Backend type: \\='direct, \\='loader-based, or \\='lsp
- :binary - Expected binary name for validation (optional, e.g., \"yamllint\")

Example:
  (flymake-collection-yamllint \"YAMLLint\" (yaml-mode yaml-ts-mode)
   :abbreviation \"f-c-y\" :type direct :binary \"yamllint\")

This registry stores all backend metadata in one place, replacing the need for
separate backend and abbreviation mapping constants.")
(provide 'flymake-constants)
;;; flymake-constants.el ends here
