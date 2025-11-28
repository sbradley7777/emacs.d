;;; flymake-lang-setup.el --- Flymake Language Mode Setup Utilities -*- lexical-binding: t -*-
;;; Commentary:
;; Shared utilities for configuring flymake in language modes.
;; Provides common patterns for standalone backends and dual backend (flymake + LSP) setups.
;;
;; Usage:
;;   (require 'flymake-lang-setup)
;;   (lang-trigger-flymake-check-timer)

;;; Code:
(require 'flymake)
(require 'flymake-registry)
(require 'core-utils)

;; External declarations
(defvar eglot--managed-mode)
(declare-function flymake-schedule-backend-check "flymake-config")
(declare-function flymake-start "flymake")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Low-Level Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 lang-validate-backend-available-p (binary backend-function)
 "Return non-nil if BINARY exists in PATH and BACKEND-FUNCTION is defined.
BINARY is the name of the executable to check for (e.g., \"mdl\", \"yamllint\", \"shellcheck\").
If BINARY is nil, no binary check is performed (for backends without executables).
BACKEND-FUNCTION is the flymake backend function symbol (e.g., \\='flymake-collection-markdownlint).
This is the standard validation check used before enabling any flymake backend."
 (and (or (null binary) (core-utils-check-command-in-path binary)) (fboundp backend-function)))

(defun
 lang-setup-flymake-backend (binary backend-function)
 "Set up standalone flymake BACKEND-FUNCTION if BINARY is available.
BINARY is the name of the executable to check for (e.g., \"mdl\", \"yamllint\").
BACKEND-FUNCTION is the flymake backend function symbol (e.g., \\='flymake-collection-markdownlint).
Adds BACKEND-FUNCTION to `flymake-diagnostic-functions' buffer-locally."
 (when
  (lang-validate-backend-available-p binary backend-function)
  (add-hook 'flymake-diagnostic-functions backend-function nil t)))

(defun
 lang-ensure-flymake-backend-after-eglot (binary backend-function)
 "Ensure BACKEND-FUNCTION is active after eglot start.
BINARY is the name of the executable to check for (e.g., \"mdl\").
BACKEND-FUNCTION is the flymake backend function symbol (e.g., \\='flymake-collection-markdownlint).
Eglot can sometimes reset the diagnostic functions list, so we re-add the backend if missing."
 (when
  (and
   (bound-and-true-p eglot--managed-mode)
   (lang-validate-backend-available-p binary backend-function))
  (unless
   (memq backend-function flymake-diagnostic-functions)
   (add-hook 'flymake-diagnostic-functions backend-function nil t)
   (flymake-start))))

(defun
 lang-add-eglot-backend-hook (binary backend-function)
 "Add hook to ensure BACKEND-FUNCTION persists after eglot start.
BINARY is the name of the executable (e.g., \"mdl\").
BACKEND-FUNCTION is the flymake backend function symbol (e.g., \\='flymake-collection-markdownlint).
This addresses the issue where eglot can reset `flymake-diagnostic-functions'."
 (add-hook
  'eglot-managed-mode-hook
  (lambda () (lang-ensure-flymake-backend-after-eglot binary backend-function))
  nil
  t))

(defun
 lang-trigger-flymake-check-timer ()
 "Trigger flymake configuration check timer.
Delegates to `flymake-schedule-backend-check' for timer management."
 (flymake-schedule-backend-check))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; High-Level Backend Setup Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Backend Setup Function Selection Guide:
;;
;; These functions provide standardized patterns for setting up Flymake diagnostics in language modes.
;; All binary names are automatically looked up from `flymake-backend-registry'.
;; Backend functions MUST be registered in the registry with :binary property set.
;;
;; 1. `flymake-lang-setup-direct-backend'
;;    When to use:
;;      - Language has a standalone linter with a direct backend function
;;      - Backend function comes from flymake-collection or similar packages
;;      - No LSP server is configured for this language
;;    Examples:
;;      - YAML: flymake-collection-yamllint (when not using LSP)
;;      - JSON: flymake-collection-jsonlint (when not using LSP)
;;    Usage:
;;      (flymake-lang-setup-direct-backend 'flymake-collection-yamllint)
;;
;; 2. `flymake-lang-setup-package-loader'
;;    When to use:
;;      - Flymake package provides its own -load function
;;      - Load function handles backend registration internally
;;      - No LSP server is configured for this language
;;    Examples:
;;      - Bash/Shell: flymake-shellcheck-load
;;    Usage:
;;      (flymake-lang-setup-package-loader 'flymake-shellcheck-load)
;;
;; 3. `flymake-lang-setup-lsp-backend'
;;    When to use:
;;      - Language ONLY has LSP server diagnostics
;;      - No standalone linter available or needed
;;      - LSP provides comprehensive diagnostics
;;    Examples:
;;      - Python: pylsp with ruff plugin (linting via LSP)
;;      - C/C++: clangd (comprehensive semantic analysis)
;;      - TOML: taplo (schema validation and linting)
;;    Usage:
;;      (flymake-lang-setup-lsp-backend)
;;
;; 4. `flymake-lang-setup-dual-backend'
;;    When to use:
;;      - Language has BOTH standalone linter AND LSP server
;;      - Both tools provide complementary diagnostics
;;      - Linter catches style issues LSP might miss
;;      - LSP provides semantic analysis linter cannot do
;;    Examples:
;;      - YAML: flymake-collection-yamllint + yaml-language-server
;;      - JSON: flymake-collection-jsonlint + vscode-json-languageserver
;;      - Markdown: flymake-collection-markdownlint + marksman
;;    Usage:
;;      (flymake-lang-setup-dual-backend 'flymake-collection-yamllint)
;;      (flymake-lang-setup-dual-backend 'flymake-shellcheck-load)
;;
;; Auto-detection in dual backend:
;;   The dual function automatically detects the function type:
;;   - Functions ending with '-load' are treated as package loaders
;;   - All other functions are treated as direct backends
;;   - Direct backends get eglot persistence hooks
;;   - Package loaders do not (they handle their own persistence)
;;
;; Decision flowchart:
;;   Has standalone linter?
;;     Yes -> Has LSP server too?
;;       Yes -> Use #4 (flymake-lang-setup-dual-backend)
;;       No  -> Is it a -load function?
;;         Yes -> Use #2 (flymake-lang-setup-package-loader)
;;         No  -> Use #1 (flymake-lang-setup-direct-backend)
;;     No  -> Use #3 (flymake-lang-setup-lsp-backend)

(defun
 flymake-lang-setup-direct-backend (backend-function)
 "Set up direct flymake backend (standalone, no LSP).
BACKEND-FUNCTION is the flymake backend symbol (e.g., \\='flymake-collection-jsonlint).

Binary name is automatically looked up from `flymake-backend-registry' :binary property.
Errors if backend is not registered or missing :binary property.

For languages that only have a standalone linter, no LSP server.
Uses direct backend functions that are manually added to `flymake-diagnostic-functions'.

If binary is not found in PATH, setup is silently skipped."
 ;; Validation: Check backend type is 'direct
 (flymake--validate-backend-type backend-function 'direct)
 (let* ((spec (flymake--find-backend-spec backend-function))
        (binary (when spec (flymake--get-backend-binary backend-function))))
   (unless spec (error "Backend %s not found in flymake-backend-registry" backend-function))
   (unless binary (error "Backend %s missing :binary property in registry" backend-function))
   (lang-setup-flymake-backend binary backend-function)
   (flymake-mode 1)
   (lang-trigger-flymake-check-timer)))

(defun
 flymake-lang-setup-package-loader (load-function)
 "Set up package-based flymake backend (standalone, no LSP).
LOAD-FUNCTION is the package setup function symbol (e.g., \\='flymake-shellcheck-load).

Binary name is automatically looked up from `flymake-backend-registry' :binary property.
Errors if backend is not registered or missing :binary property.

For flymake packages that provide their own load functions instead of
direct backend functions.  The load function typically handles adding
the backend to `flymake-diagnostic-functions' and enabling `flymake-mode'.

If binary is not found in PATH, setup is silently skipped."
 ;; Validation: Check backend type is 'loader-based
 (flymake--validate-backend-type load-function 'loader-based)
 (let* ((spec (flymake--find-backend-spec load-function))
        (binary (when spec (flymake--get-backend-binary load-function))))
   (unless spec (error "Backend %s not found in flymake-backend-registry" load-function))
   (unless binary (error "Backend %s missing :binary property in registry" load-function))
   (when
    (lang-validate-backend-available-p binary load-function)
    (funcall load-function)
    (lang-trigger-flymake-check-timer))))

(defun
 flymake-lang-setup-lsp-backend ()
 "Set up flymake for LSP-only diagnostics via eglot.
Enables `flymake-mode' to receive diagnostics from eglot LSP backend.
No standalone linter is configured.

This is for languages that only have LSP server diagnostics (e.g., clangd for C/C++,
taplo for TOML) and do not have a separate standalone linter."
 (flymake-mode 1))

(defun
 flymake-lang-setup-dual-backend (function)
 "Set up dual flymake backend: direct or package + LSP via eglot.
FUNCTION is either a direct backend (e.g., \\='flymake-collection-markdownlint)
or a package load function (e.g., \\='flymake-shellcheck-load).

Binary name is automatically looked up from `flymake-backend-registry' :binary property.
Errors if backend is not registered or missing :binary property.

Validates backend configuration against `flymake-backend-registry':
- Uses `:type' property to determine backend type (preferred method)
- Validates mode compatibility for registered backends
- Requires :binary property to be set in registry

Automatically detects function type:
- \\='loader-based backends: Package load functions (e.g., flymake-shellcheck-load)
- \\='direct backends: Direct backend functions (e.g., flymake-collection-yamllint)

This handles the common pattern where a language has both:
1. A standalone flymake backend (linter or package)
2. An LSP server via eglot

IMPORTANT LIMITATION:
- Direct backends: Adds eglot hook to persist backend after eglot starts
- Package backends: Does NOT add eglot hook (package backends add internal
  functions we cannot track, and typically handle persistence themselves)

If binary is not found in PATH, setup is silently skipped."
 ;; Query registry for backend metadata
 (let* ((spec (flymake--find-backend-spec function))
        (backend-type (when spec (flymake--registry-get-property function :type)))
        (binary (when spec (flymake--get-backend-binary function)))
        (use-loader nil))

   ;; Validation: Check if backend is registered
   (unless spec (error "Backend %s not found in flymake-backend-registry" function))

   ;; Validation: Check binary is defined
   (unless binary (error "Backend %s missing :binary property in registry" function))

   ;; Validation: Check mode compatibility (using helper)
   (flymake--check-mode-compatibility function spec)

   ;; Determine backend type: use registry first, fallback to heuristic
   (setq
    use-loader
    (if
     backend-type (eq backend-type 'loader-based)
     ;; Fallback to current string suffix heuristic
     (string-suffix-p "-load" (symbol-name function))))

   ;; Setup based on type
   (if
    use-loader
    ;; Package load function - no eglot hook needed
    ;; Package internally adds its own backend function (e.g., flymake-shellcheck--checker)
    ;; which we cannot track or persist via our hook mechanism
    (flymake-lang-setup-package-loader function)
    ;; Direct backend function - add eglot hook for persistence
    ;; Eglot can reset flymake-diagnostic-functions, so we ensure backend persists
    (progn
     (flymake-lang-setup-direct-backend function) (lang-add-eglot-backend-hook binary function)))))

(provide 'flymake-lang-setup)
;;; flymake-lang-setup.el ends here
