;;; registry-query.el --- Registry Query Functions -*- lexical-binding: t -*-
;;; Commentary:
;; Query and access functions for registry data structures.
;;
;; Registry format: (IDENTIFIER DESCRIPTION MODES . PROPERTIES)
;;
;; Query functions:
;;   - registry-find-entry          - Find entry by identifier
;;   - registry-get-property        - Get property value
;;   - registry-get-description     - Get description string
;;   - registry-get-modes           - Get supported modes
;;   - registry--get-all-identifiers - Get all identifiers
;;   - registry-find-by-mode        - Find entries for a mode
;;   - registry--find-all-by-mode    - Find all entries for a mode
;;
;; Cross-registry queries:
;;   - registry-has-available-lsp-for-mode-p - Check if LSP available for mode
;;   - registry-should-defer-check-p         - Check if backend should defer check

;;; Code:
(require 'cl-lib)

;; Forward declaration for registry-mode-compatible-p
(declare-function registry-mode-compatible-p "registry-validation")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Core Query Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 registry-find-entry (registry identifier)
 "Find entry in REGISTRY with IDENTIFIER.
Return the full entry or nil if not found.
REGISTRY is a list of entries following the registry format.
IDENTIFIER is the symbol to look up (first element of entry)."
 (assq identifier registry))

(defun
 registry-get-property (registry identifier property)
 "Get PROPERTY for IDENTIFIER from REGISTRY.
Return the property value or nil if not found.
PROPERTY is a keyword like :binary, :type, :install-hint, etc.
REGISTRY is the registry to search in.
IDENTIFIER is the entry identifier symbol."
 (let ((entry (registry-find-entry registry identifier)))
   (when entry (plist-get (nthcdr 3 entry) property))))

(defun
 registry-get-description (registry identifier)
 "Get human-readable description for IDENTIFIER from REGISTRY.
Return the description string or the identifier symbol as fallback.
REGISTRY is the registry to search in.
IDENTIFIER is the entry identifier symbol."
 (let ((entry (registry-find-entry registry identifier)))
   (if entry (nth 1 entry) (format "%s" identifier))))

(defun
 registry-get-modes (registry identifier)
 "Get list of supported modes for IDENTIFIER from REGISTRY.
Return list of mode symbols or special value like (multiple).
REGISTRY is the registry to search in.
IDENTIFIER is the entry identifier symbol."
 (let ((entry (registry-find-entry registry identifier)))
   (when entry (nth 2 entry))))

(defun
 registry--get-all-identifiers (registry &optional filter-fn)
 "Get list of all identifiers in REGISTRY.
If FILTER-FN is provided, only include entries where (FILTER-FN entry) is non-nil.
REGISTRY is the registry to query.
FILTER-FN is optional predicate function receiving entry as argument.

Example:
  (registry--get-all-identifiers reg
    (lambda (e) (not (plist-get (nthcdr 3 e) :disabled))))"
 (let ((identifiers nil))
   (dolist
    (entry registry)
    (when (or (null filter-fn) (funcall filter-fn entry)) (push (car entry) identifiers)))
   (nreverse identifiers)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Mode-Based Query Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 registry-find-by-mode (registry mode &optional filter-fn)
 "Find first entry in REGISTRY that supports MODE.
Return the identifier (first element) of matching entry, or nil.
If FILTER-FN is provided, only consider entries where (FILTER-FN entry) is non-nil.
REGISTRY is the registry to search.
MODE is the major mode symbol to find.
FILTER-FN is optional predicate function.

Example:
  (registry-find-by-mode eglot-registry \\='python-mode
    (lambda (e) (not (plist-get (nthcdr 3 e) :disabled))))"
 (let ((result nil))
   (catch
    'found
    (dolist
     (entry registry)
     (when
      (or (null filter-fn) (funcall filter-fn entry))
      (let ((modes (nth 2 entry)))
        (when (registry-mode-compatible-p modes mode) (throw 'found (setq result (car entry))))))))
   result))

(defun
 registry--find-all-by-mode (registry mode &optional filter-fn)
 "Find all entries in REGISTRY that support MODE.
Return list of identifiers (first elements) of matching entries.
If FILTER-FN is provided, only consider entries where (FILTER-FN entry) is non-nil.
REGISTRY is the registry to search.
MODE is the major mode symbol to find.
FILTER-FN is optional predicate function."
 (let ((results nil))
   (dolist
    (entry registry)
    (when
     (or (null filter-fn) (funcall filter-fn entry))
     (let ((modes (nth 2 entry)))
       (when (registry-mode-compatible-p modes mode) (push (car entry) results)))))
   (nreverse results)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Cross-Registry Queries
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 registry-has-available-lsp-for-mode-p (lsp-registry mode)
 "Check if MODE has an available LSP server in LSP-REGISTRY.
Return t if an enabled LSP server exists for MODE, nil otherwise.

An LSP server is considered available if:
- It supports the given MODE
- It is not disabled in the registry
- Its binary exists in PATH (checked by constructor)

LSP-REGISTRY is the eglot LSP server registry to query.
MODE is the major mode symbol to check (e.g., \\='python-mode, \\='yaml-mode).

Example:
  (registry-has-available-lsp-for-mode-p eglot-lsp-server-registry \\='python-mode)
  => t  ; If pylsp is enabled and available
  (registry-has-available-lsp-for-mode-p eglot-lsp-server-registry \\='sh-mode)
  => nil ; If bash-language-server is disabled"
 (let ((lsp-identifier
        (registry-find-by-mode lsp-registry mode
                               (lambda
                                (entry)
                                (let ((props (nthcdr 3 entry)))
                                  (not (plist-get props :disabled)))))))
   (and lsp-identifier t)))

(defun
 registry-should-defer-check-p (backend-registry lsp-registry backend-identifier mode)
 "Check if BACKEND-IDENTIFIER should defer initial Flymake check.
Return t if backend has defer-check enabled AND LSP is available for MODE.

This cross-registry query coordinates between Flymake backends and LSP servers
to prevent \\='Canceling obsolete check\\=' warnings in dual-backend scenarios.

BACKEND-REGISTRY is the Flymake backend registry to query.
LSP-REGISTRY is the eglot LSP server registry to query.
BACKEND-IDENTIFIER is the backend identifier symbol to check.
MODE is the major mode symbol (e.g., \\='python-mode, \\='yaml-mode).

Example:
  (registry-should-defer-check-p
   flymake-backend-registry
   eglot-lsp-server-registry
   \\='flymake-collection-yamllint
   \\='yaml-mode)
  => t  ; If yamllint has :defer-check t and yaml-language-server is available"
 (and
  (registry-entry-defer-check-p backend-registry backend-identifier)
  (registry-has-available-lsp-for-mode-p lsp-registry mode)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Filtering Helpers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 registry-filter-disabled (registry identifier-list)
 "Filter IDENTIFIER-LIST, removing entries marked as disabled in REGISTRY.
Return new list with disabled entries removed.
Only filters symbol identifiers; preserves non-symbol elements unchanged.

REGISTRY is the registry to check for :disabled flags.
IDENTIFIER-LIST is list of identifiers to filter.

This function checks each symbol identifier against REGISTRY and removes
those with :disabled t property.  Non-symbol elements (like hook markers)
are preserved in the output.

Example:
  (registry-filter-disabled
    flymake-backend-registry
    \\='(python-flymake sh-shellcheck-flymake t \\='elisp-flymake-byte-compile))
  => (python-flymake t \\='elisp-flymake-byte-compile)
  ;; Removes sh-shellcheck-flymake if :disabled t in registry"
 (cl-remove-if
  (lambda
   (identifier) (when (symbolp identifier) (not (registry-entry-enabled-p registry identifier))))
  identifier-list))

(provide 'registry-query)
;;; registry-query.el ends here
