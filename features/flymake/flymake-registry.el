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
(require 'core-logging)
(require 'registry-init)
(require 'registry-query)
(require 'registry-validation)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Flymake Constructor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(cl-defun
 flymake-registry-create-backend
 (identifier
  description
  modes
  &key
  binary
  disabled
  disabled-reason
  (priority 100)
  url
  abbreviation
  type
  loader)
 "Create flymake backend registry entry by extending base entry.

Inherits common properties from base constructor:
  :binary, :disabled, :disabled-reason, :priority, :url

Flymake-specific required keywords:
  :abbreviation - Short identifier for diagnostics display (e.g., \"p-f\")
  :type         - Backend type: \\='direct, \\='loader-based, or \\='lsp

Flymake-specific optional keywords:
  :loader - Function symbol to call for loading this backend

Example:
  (flymake-registry-create-backend
   \\='python-flymake \"Python built-in\" \\='(python-mode python-ts-mode)
   :abbreviation \"p-f\"
   :type \\='direct
   :binary \"(built-in)\"
   :priority 100
   :url \"https://docs.python.org/3/library/pydoc.html\")"
 (unless abbreviation (error "Flymake backend %s missing required :abbreviation" identifier))
 (unless type (error "Flymake backend %s missing required :type" identifier))
 (unless
  (memq type '(direct loader-based lsp))
  (error
   "Flymake backend %s has invalid :type %s (must be direct, loader-based, or lsp)"
   identifier
   type))
 (let* ((base-entry
         (registry-create-base-entry
          identifier
          description
          modes
          :binary binary
          :disabled disabled
          :disabled-reason disabled-reason
          :priority priority
          :url url))
        (base-props (nthcdr 3 base-entry))
        (flymake-props (list :abbreviation abbreviation :type type)))
   (when loader (setq flymake-props (plist-put flymake-props :loader loader)))
   (let ((merged-props (registry-merge-properties base-props flymake-props)))
     (append (list identifier description modes) merged-props))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Registry Constant
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defconst
 flymake-backend-registry
 (list
  (flymake-registry-create-backend
   'flymake-aspell--check
   "Aspell spell checking"
   '(text-mode prog-mode)
   :abbreviation "f-a--"
   :type 'direct
   :binary "aspell"
   :priority 100
   :url "https://github.com/GNUAspell/aspell")
  (flymake-registry-create-backend
   'python-flymake
   "Python built-in"
   '(python-mode python-ts-mode)
   :abbreviation "p-f"
   :type 'direct
   :binary "(built-in)"
   :priority 100
   :url "https://docs.python.org/3/library/pydoc.html")
  (flymake-registry-create-backend
   'elisp-flymake-byte-compile
   "Elisp Byte Compile"
   '(emacs-lisp-mode lisp-interaction-mode)
   :abbreviation "e-f-b-c"
   :type 'direct
   :binary "(built-in)"
   :priority 100
   :url "https://www.gnu.org/software/emacs/manual/html_node/elisp/Byte-Compilation.html")
  (flymake-registry-create-backend
   'elisp-flymake-checkdoc
   "Elisp Checkdoc"
   '(emacs-lisp-mode lisp-interaction-mode)
   :abbreviation "e-f-c"
   :type 'direct
   :binary "(built-in)"
   :priority 100
   :url "https://www.gnu.org/software/emacs/manual/html_node/elisp/Documentation-Tips.html")
  (flymake-registry-create-backend
   'flymake-shellcheck-load
   "ShellCheck linter (loader)"
   '(sh-mode sh-ts-mode bash-ts-mode)
   :abbreviation "f-s-l"
   :type 'loader-based
   :binary "shellcheck"
   :priority 100
   :url "https://github.com/federicotdn/flymake-shellcheck")
  (flymake-registry-create-backend
   'flymake-shellcheck--backend
   "ShellCheck linter (backend)"
   '(sh-mode sh-ts-mode bash-ts-mode)
   :abbreviation "f-s--"
   :type 'direct
   :binary "shellcheck"
   :priority 100
   :url "https://github.com/federicotdn/flymake-shellcheck")
  (flymake-registry-create-backend
   'sh-shellcheck-flymake
   "ShellCheck built-in"
   '(sh-mode sh-ts-mode bash-ts-mode)
   :abbreviation "s-s-f"
   :type 'direct
   :binary "shellcheck"
   :priority 100
   :url "https://github.com/koalaman/shellcheck"
   :disabled t
   :disabled-reason "Requires ShellCheck 0.7.0+ for --format=json1 support. Current system has 0.6.0. See: https://github.com/sbradley7777/emacs.d/issues/48")
  (flymake-registry-create-backend
   'flymake-collection-yamllint
   "YAMLLint"
   '(yaml-mode yaml-ts-mode)
   :abbreviation "f-c-y"
   :type 'direct
   :binary "yamllint"
   :priority 100
   :url "https://github.com/adrienverge/yamllint")
  (flymake-registry-create-backend
   'flymake-collection-jsonlint
   "JSONLint"
   '(js-json-mode json-ts-mode)
   :abbreviation "f-c-j"
   :type 'direct
   :binary "jsonlint"
   :priority 100
   :url "https://github.com/zaach/jsonlint")
  (flymake-registry-create-backend
   'flymake-collection-markdownlint
   "MarkdownLint"
   '(markdown-mode markdown-ts-mode)
   :abbreviation "f-c-m"
   :type 'direct
   :binary "markdownlint"
   :priority 100
   :url "https://github.com/DavidAnson/markdownlint")
  (flymake-registry-create-backend
   'eglot-flymake-backend
   "Eglot LSP"
   '(multiple)
   :abbreviation "e-f-b"
   :type 'lsp
   :priority 100
   :url "https://github.com/joaotavora/eglot"))
 "Registry of Flymake backends using type-safe constructors.

All entries created using `flymake-registry-create-backend' for validation.

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

Example:
  (flymake-registry-create-backend
   \\='flymake-collection-yamllint \"YAMLLint\" \\='(yaml-mode yaml-ts-mode)
   :abbreviation \"f-c-y\"
   :type \\='direct
   :binary \"yamllint\"
   :priority 100
   :url \"https://github.com/adrienverge/yamllint\")

This registry uses constructors for type safety and validation at creation time.")

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
 flymake-registry-find-backend (backend-symbol)
 "Find backend specification in `flymake-backend-registry' for BACKEND-SYMBOL.
Returns the backend spec entry (FUNCTION-SYMBOL DESCRIPTION MODES) or nil if not found."
 (registry-find-entry flymake-backend-registry backend-symbol))

(defun
 flymake-registry-get-property (backend-symbol property)
 "Get PROPERTY for BACKEND-SYMBOL from `flymake-backend-registry'.
PROPERTY is a keyword like :abbreviation, :loader, or :type.
Returns nil if backend not found or property not set.

The registry format is (FUNCTION-SYMBOL DESCRIPTION MODES . PROPERTIES)
where PROPERTIES is a plist starting at index 3."
 (registry-get-property flymake-backend-registry backend-symbol property))

(defun
 flymake-registry-get-description (backend-symbol)
 "Get human-readable description for BACKEND-SYMBOL.
Looks up the backend in `flymake-backend-registry' and returns its description.
Falls back to the backend function name if not found in registry."
 (registry-get-description flymake-backend-registry backend-symbol))

(defun
 flymake-registry-get-binary (backend-symbol)
 "Get expected binary name for BACKEND-SYMBOL from registry.
Returns the :binary property value if set, nil otherwise.
BACKEND-SYMBOL is the backend function symbol to look up."
 (flymake-registry-get-property backend-symbol :binary))

(defun
 flymake-registry-get-modes (backend-symbol)
 "Get list of supported modes for BACKEND-SYMBOL from registry.
Returns list of mode symbols or special value like (multiple).
BACKEND-SYMBOL is the backend function symbol to look up."
 (registry-get-modes flymake-backend-registry backend-symbol))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Validation Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 flymake-backend-available-p (binary backend-function)
 "Return non-nil if BINARY exists, BACKEND-FUNCTION is defined, and backend is not disabled.
BINARY is the name of the executable to check for (e.g., \"mdl\", \"yamllint\", \"shellcheck\").
Special values:
  - nil: No binary check is performed (for backends without executables)
  - \"(built-in)\": Backend is built into Emacs, skip executable check
BACKEND-FUNCTION is the flymake backend function symbol (e.g., \\='flymake-collection-markdownlint).

This function enforces the :disabled flag from the registry.
Backends marked with :disabled t will return nil, preventing them from being enabled.

This is the standard validation check used before enabling any flymake backend."
 (registry-entry-available-p
  flymake-backend-registry backend-function binary backend-function nil))

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

(defun
 flymake--mode-compatible-p (supported-modes)
 "Check if current `major-mode' is compatible with SUPPORTED-MODES.
Returns t if current mode matches exactly or derives from any supported mode.
Handles special case where SUPPORTED-MODES is (multiple).

SUPPORTED-MODES is a list of mode symbols from registry entry."
 (registry-mode-compatible-p supported-modes major-mode))

(defun
 flymake--validate-binary-name (function binary)
 "Validate BINARY name against registry for FUNCTION.
Returns t if valid or no :binary property exists, nil if mismatch.
Logs warning message when mismatch detected.

FUNCTION is the backend function symbol.
BINARY is the executable name being passed to setup."
 (let ((expected-binary (flymake-registry-get-property function :binary)))
   (if
    (and expected-binary (not (string= binary expected-binary)))
    (progn
     (logging-warning
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
 (let ((actual-type (flymake-registry-get-property function :type)))
   (if
    (and actual-type (not (eq actual-type expected-type)))
    (progn
     (logging-warning
      "Backend %s registered as %s but called as %s backend" function actual-type expected-type)
     nil)
    t)))

(defun
 flymake--validate-registry-entry (entry)
 "Validate a single registry ENTRY for completeness.
Returns nil if valid, error message string if invalid.
Does not signal errors, only returns validation result.

ENTRY is a registry entry in format (FUNCTION-SYMBOL DESCRIPTION MODES . PROPERTIES)."
 (or
  (registry-validate-entry entry '(:type :abbreviation))
  (let ((func (nth 0 entry))
        (props (nthcdr 3 entry)))
    (cond
     ((not (memq (plist-get props :type) '(direct loader-based lsp)))
      (format "Registry entry for %s has invalid :type: %s" func (plist-get props :type)))
     (t
      nil)))))

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
       (if flymake-strict-mode-checking (error "%s" msg) (logging-warning "%s" msg))
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
