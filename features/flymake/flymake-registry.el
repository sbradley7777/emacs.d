;;; flymake-registry.el --- Flymake Backend Registry and Validation -*- lexical-binding: t -*-
;;; Commentary:
;; Registry of Flymake backends with metadata, query functions, and validation.
;; Centralizes all registry-related functionality including:
;; - Backend registry constant with metadata
;; - Query functions for retrieving backend information
;; - Validation functions for backend configuration
;; - Strict validation mode options

;;; Code:
(require 'core-logging)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Registry Constant
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
   (flymake-shellcheck-load
    "ShellCheck linter"
    (sh-mode sh-ts-mode bash-ts-mode)
    :abbreviation "f-s--"
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Customization Variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defcustom
 flymake-strict-validation nil
 "When non-nil, validate registry on load and error if invalid entries found.
This enables strict validation of the `flymake-backend-registry' at load time.
If any registry entry is missing required properties or has invalid values,
an error will be signaled during initialization.

Recommended for development and testing, not for production use."
 :type 'boolean
 :group 'flymake)

(defcustom
 flymake-require-registry-entry nil
 "When non-nil, require all backends to be registered in the registry.
If nil, fall back to heuristic detection for unregistered backends.

When enabled, any backend not found in `flymake-backend-registry' will
cause an error instead of falling back to naming convention heuristics.

This is a strict mode option that enforces registry completeness."
 :type 'boolean
 :group 'flymake)

(defcustom
 flymake-strict-mode-checking nil
 "When non-nil, error on mode compatibility mismatches.
If nil, only warn about mismatches (default behavior).

When enabled, using a backend in an incompatible major mode will cause
an error instead of just a warning.

This is a strict mode option that prevents invalid configurations."
 :type 'boolean
 :group 'flymake)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Registry Query Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 flymake--find-backend-spec (backend-symbol)
 "Find backend specification in `flymake-backend-registry' for BACKEND-SYMBOL.
Returns the backend spec entry (FUNCTION-SYMBOL DESCRIPTION MODES) or nil if not found."
 (assq backend-symbol flymake-backend-registry))

(defun
 flymake--registry-get-property (backend-symbol property)
 "Get PROPERTY for BACKEND-SYMBOL from `flymake-backend-registry'.
PROPERTY is a keyword like :abbreviation, :loader, or :type.
Returns nil if backend not found or property not set.

The registry format is (FUNCTION-SYMBOL DESCRIPTION MODES . PROPERTIES)
where PROPERTIES is a plist starting at index 3."
 (let ((spec (assq backend-symbol flymake-backend-registry)))
   (when spec (plist-get (nthcdr 3 spec) property))))

(defun
 flymake--get-backend-description (backend-symbol)
 "Get human-readable description for BACKEND-SYMBOL.
Looks up the backend in `flymake-backend-registry' and returns its description.
Falls back to the backend function name if not found in registry."
 (let ((spec (flymake--find-backend-spec backend-symbol)))
   (if spec (nth 1 spec) (format "%s" backend-symbol))))

(defun
 flymake--get-backend-binary (backend-symbol)
 "Get expected binary name for BACKEND-SYMBOL from registry.
Returns the :binary property value if set, nil otherwise.
BACKEND-SYMBOL is the backend function symbol to look up."
 (flymake--registry-get-property backend-symbol :binary))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Validation Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 flymake--mode-compatible-p (supported-modes)
 "Check if current `major-mode' is compatible with SUPPORTED-MODES.
Returns t if current mode matches exactly or derives from any supported mode.
Handles special case where SUPPORTED-MODES is (multiple).

SUPPORTED-MODES is a list of mode symbols from registry entry."
 (or
  (eq (car supported-modes) 'multiple)
  (memq major-mode supported-modes)
  (cl-some (lambda (mode) (derived-mode-p mode)) supported-modes)))

(defun
 flymake--validate-binary-name (function binary)
 "Validate BINARY name against registry for FUNCTION.
Returns t if valid or no :binary property exists, nil if mismatch.
Logs warning message when mismatch detected.

FUNCTION is the backend function symbol.
BINARY is the executable name being passed to setup."
 (let ((expected-binary (flymake--registry-get-property function :binary)))
   (if
    (and expected-binary (not (string= binary expected-binary)))
    (progn
     (core-message-warning
      "Backend %s expects binary '%s' but '%s' was specified" function expected-binary binary)
     nil)
    t)))

(defun
 flymake--validate-backend-type (function expected-type)
 "Validate that FUNCTION has EXPECTED-TYPE in registry.
EXPECTED-TYPE should be \\='direct, \\='loader-based, or \\='lsp.
Returns t if valid or not registered, nil if type mismatch.
Logs warning message when mismatch detected.

FUNCTION is the backend function symbol.
EXPECTED-TYPE is the type this function should have in the registry."
 (let ((actual-type (flymake--registry-get-property function :type)))
   (if
    (and actual-type (not (eq actual-type expected-type)))
    (progn
     (core-message-warning
      "Backend %s registered as %s but called as %s backend" function actual-type expected-type)
     nil)
    t)))

(defun
 flymake--validate-registry-entry (entry)
 "Validate a single registry ENTRY for completeness.
Returns nil if valid, error message string if invalid.
Does not signal errors, only returns validation result.

ENTRY is a registry entry in format (FUNCTION-SYMBOL DESCRIPTION MODES . PROPERTIES)."
 (let ((func (nth 0 entry))
       (desc (nth 1 entry))
       (modes (nth 2 entry))
       (props (nthcdr 3 entry)))
   (cond
    ((not (plist-get props :type))
     (format "Registry entry for %s missing :type property" func))
    ((not (memq (plist-get props :type) '(direct loader-based lsp)))
     (format "Registry entry for %s has invalid :type: %s" func (plist-get props :type)))
    ((not (plist-get props :abbreviation))
     (format "Registry entry for %s missing :abbreviation property" func))
    (t
     nil))))

(defun
 flymake--check-mode-compatibility (function spec)
 "Check mode compatibility for FUNCTION using SPEC from registry.
Returns t if compatible or spec is nil.
Logs warning if mode incompatible, or errors if `flymake-strict-mode-checking' is non-nil.

FUNCTION is the backend function symbol.
SPEC is the full registry entry or nil if backend not registered."
 (if
  (not spec) t
  (let ((supported-modes (nth 2 spec)))
    (if
     (flymake--mode-compatible-p supported-modes) t
     (let ((msg
            (format
             "Backend %s not registered for %s (supports: %s)"
             function
             major-mode
             supported-modes)))
       (if flymake-strict-mode-checking (error "%s" msg) (core-message-warning "%s" msg))
       nil)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Registry Validation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 flymake--validate-registry ()
 "Validate all entries in `flymake-backend-registry' for completeness.
Signals error if any entry is missing required properties or has invalid values.
Uses `flymake--validate-registry-entry' to check each entry.

This function is automatically called at load time when `flymake-strict-validation'
is non-nil."
 (dolist
  (entry flymake-backend-registry)
  (let ((error-msg (flymake--validate-registry-entry entry)))
    (when error-msg (error "%s" error-msg)))))

;; Run registry validation if strict mode enabled
(when flymake-strict-validation (flymake--validate-registry))

(provide 'flymake-registry)
;;; flymake-registry.el ends here
