;;; flymake-constants.el --- Flymake Configuration Constants -*- lexical-binding: t -*-
;;; Commentary:
;; This file contains constants for Flymake backend configuration and diagnostics display.
;; Constants define the known backends, their descriptions, and display name mappings.

;;; Code:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defconst
 flymake-diagnostics-backend-abbreviations
 '(("e-f-b-c" . "Elisp Byte Compile")
   ("e-f-c" . "Elisp Checkdoc")
   ("e-f-b" . "Eglot LSP")
   ("f-r" . "Ruff Python linter")
   ("f-a" . "Aspell spell checker")
   ("f-s" . "ShellCheck linter")
   ("s-s-f" . "ShellCheck built-in")
   ("p-f" . "Python built-in")
   ("flymake" . "Flymake"))
 "Mapping of abbreviated Flymake backend names to user-friendly display names.
Used by the diagnostics table to convert abbreviated backend identifiers (like \\='e-f-b\\=')
to human-readable names (like \\='Eglot LSP\\=').
Each entry is (ABBREVIATION-PATTERN . FRIENDLY-NAME) where ABBREVIATION-PATTERN
is a regex to match against abbreviated backend identifiers shown in the diagnostics buffer.
Patterns are checked in order, so more specific patterns should come first
(e.g., \\='e-f-b-c\\=' before \\='e-f-b\\=').")

(defconst
 flymake-backend-registry
 '((flymake-aspell--check "Aspell spell checking" (text-mode prog-mode))
   (flymake-ruff--run-checker "Ruff Python linter" (python-mode python-ts-mode))
   (python-flymake "Python built-in" (python-mode python-ts-mode))
   (elisp-flymake-byte-compile "Elisp Byte Compile" (emacs-lisp-mode lisp-interaction-mode))
   (elisp-flymake-checkdoc "Elisp Checkdoc" (emacs-lisp-mode lisp-interaction-mode))
   (flymake-shellcheck--backend "ShellCheck linter" (sh-mode sh-ts-mode bash-ts-mode))
   (sh-shellcheck-flymake "ShellCheck built-in" (sh-mode sh-ts-mode bash-ts-mode))
   (eglot-flymake-backend "Eglot LSP" (multiple)))
 "Registry of known Flymake backends with their descriptions and supported modes.
Used by backend availability checking to display user-friendly backend names.
Each entry is (FUNCTION-SYMBOL DESCRIPTION MODES) where:
- FUNCTION-SYMBOL is the backend function name (e.g., flymake-ruff--run-checker)
- DESCRIPTION is a user-friendly description (e.g., \\='Ruff Python linter\\=')
- MODES is a list of major modes this backend supports")
(provide 'flymake-constants)
;;; flymake-constants.el ends here
