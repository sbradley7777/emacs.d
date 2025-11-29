;;; core-registry-validation.el --- Registry Validation Functions -*- lexical-binding: t -*-
;;; Commentary:
;; Validation functions for registry entries and structure.
;;
;; Validation functions:
;;   - core-registry-validate-entry       - Validate single entry structure
;;   - core-registry-validate-all         - Validate entire registry
;;   - core-registry-mode-compatible-p    - Check mode compatibility
;;
;; These functions ensure registry entries are well-formed and
;; contain required properties.

;;; Code:
(require 'cl-lib)

;; Forward declarations
(declare-function core-registry-find-entry "core-registry-query")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Mode Compatibility
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 core-registry-mode-compatible-p (supported-modes current-mode)
 "Check if CURRENT-MODE is compatible with SUPPORTED-MODES.
Return t if mode matches exactly, derives from any supported mode,
or if SUPPORTED-MODES contains the special value (multiple).

SUPPORTED-MODES is a list of mode symbols from a registry entry.
CURRENT-MODE is the mode symbol to check (typically `major-mode')."
 (or
  (eq (car supported-modes) 'multiple) (memq current-mode supported-modes)
  (and
   current-mode
   (cl-some (lambda (mode) (provided-mode-derived-p current-mode mode)) supported-modes))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Structure Validation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 core-registry-validate-entry (entry &optional required-properties)
 "Validate ENTRY structure and optionally check REQUIRED-PROPERTIES.
Return nil if valid, or error message string if invalid.

ENTRY should be in format: (IDENTIFIER DESCRIPTION MODES . PROPERTIES)
REQUIRED-PROPERTIES is optional list of required property keywords.

Example:
  (core-registry-validate-entry entry \\='(:binary :type))
  Return error message if :binary or :type is missing."
 (let ((identifier (nth 0 entry))
       (description (nth 1 entry))
       (modes (nth 2 entry))
       (props (nthcdr 3 entry)))
   (cond
    ((not (symbolp identifier))
     (format "Entry identifier must be symbol, got: %s" identifier))
    ((not (stringp description))
     (format "Entry %s: description must be string, got: %s" identifier description))
    ((not (listp modes))
     (format "Entry %s: modes must be list, got: %s" identifier modes))
    ((not (zerop (mod (length props) 2)))
     (format "Entry %s: properties must be even-length plist" identifier))
    ((and
      required-properties
      (cl-some (lambda (prop) (not (plist-member props prop))) required-properties))
     (let ((missing (cl-remove-if (lambda (p) (plist-member props p)) required-properties)))
       (format "Entry %s missing required properties: %s" identifier missing)))
    (t
     nil))))

(defun
 core-registry-validate-all (registry &optional required-properties)
 "Validate all entries in REGISTRY.
Signals error if any entry is invalid.
REGISTRY is the registry to validate.
REQUIRED-PROPERTIES is optional list of required property keywords for all entries."
 (dolist
  (entry registry)
  (let ((error-msg (core-registry-validate-entry entry required-properties)))
    (when error-msg (error "%s" error-msg)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Entry Availability
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 core-registry-entry-available-p
 (registry identifier binary-or-lsp function-symbol &optional is-lsp)
 "Check if IDENTIFIER in REGISTRY is available for use.
Return non-nil if entry is not disabled, binary/LSP-server exists, and function is defined.

REGISTRY is the registry to check.
IDENTIFIER is the entry identifier symbol to look up.
BINARY-OR-LSP is either a binary name (e.g., \"shellcheck\") or LSP server name (e.g., \"pylsp\").
  Special values:
  - nil: No binary check performed (for entries without executables)
  - \"(built-in)\": Entry is built into Emacs, skip executable check
FUNCTION-SYMBOL is the function symbol to check with `fboundp'.
IS-LSP if non-nil, treat BINARY-OR-LSP as LSP server (different availability check).

This function enforces the :disabled flag from the registry.
Entries marked with :disabled t will return nil, preventing them from being enabled.

Example:
  ;; Check flymake backend
  (core-registry-entry-available-p
    flymake-backend-registry \\='python-flymake \"(built-in)\" \\='python-flymake nil)

  ;; Check LSP server
  (core-registry-entry-available-p
    eglot-lsp-server-registry \\='python-mode \"pylsp\" nil t)"
 (let* ((entry (core-registry-find-entry registry identifier))
        (props (when entry (nthcdr 3 entry)))
        (disabled (when props (plist-get props :disabled))))
   (and
    (not disabled)
    (if
     is-lsp (executable-find binary-or-lsp)
     (or
      (null binary-or-lsp) (string= binary-or-lsp "(built-in)") (executable-find binary-or-lsp)))
    (fboundp function-symbol))))

(provide 'core-registry-validation)
;;; core-registry-validation.el ends here
