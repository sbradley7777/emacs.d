;;; core-registry-query.el --- Registry Query Functions -*- lexical-binding: t -*-
;;; Commentary:
;; Query and access functions for registry data structures.
;;
;; Registry format: (IDENTIFIER DESCRIPTION MODES . PROPERTIES)
;;
;; Query functions:
;;   - core-registry-find-entry          - Find entry by identifier
;;   - core-registry-get-property        - Get property value
;;   - core-registry-get-description     - Get description string
;;   - core-registry-get-modes           - Get supported modes
;;   - registry--get-all-identifiers - Get all identifiers
;;   - core-registry-find-by-mode        - Find entries for a mode
;;   - registry--find-all-by-mode    - Find all entries for a mode
;;
;; Iteration helpers:
;;   - registry--map-entries         - Map function over entries
;;   - registry--filter-entries      - Filter entries by predicate

;;; Code:
(require 'cl-lib)

;; Forward declaration for core-registry-mode-compatible-p
(declare-function core-registry-mode-compatible-p "core-registry-validation")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Core Query Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 core-registry-find-entry (registry identifier)
 "Find entry in REGISTRY with IDENTIFIER.
Return the full entry or nil if not found.
REGISTRY is a list of entries following the registry format.
IDENTIFIER is the symbol to look up (first element of entry)."
 (assq identifier registry))

(defun
 core-registry-get-property (registry identifier property)
 "Get PROPERTY for IDENTIFIER from REGISTRY.
Return the property value or nil if not found.
PROPERTY is a keyword like :binary, :type, :install-hint, etc.
REGISTRY is the registry to search in.
IDENTIFIER is the entry identifier symbol."
 (let ((entry (core-registry-find-entry registry identifier)))
   (when entry (plist-get (nthcdr 3 entry) property))))

(defun
 core-registry-get-description (registry identifier)
 "Get human-readable description for IDENTIFIER from REGISTRY.
Return the description string or the identifier symbol as fallback.
REGISTRY is the registry to search in.
IDENTIFIER is the entry identifier symbol."
 (let ((entry (core-registry-find-entry registry identifier)))
   (if entry (nth 1 entry) (format "%s" identifier))))

(defun
 core-registry-get-modes (registry identifier)
 "Get list of supported modes for IDENTIFIER from REGISTRY.
Return list of mode symbols or special value like (multiple).
REGISTRY is the registry to search in.
IDENTIFIER is the entry identifier symbol."
 (let ((entry (core-registry-find-entry registry identifier)))
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
 core-registry-find-by-mode (registry mode &optional filter-fn)
 "Find first entry in REGISTRY that supports MODE.
Return the identifier (first element) of matching entry, or nil.
If FILTER-FN is provided, only consider entries where (FILTER-FN entry) is non-nil.
REGISTRY is the registry to search.
MODE is the major mode symbol to find.
FILTER-FN is optional predicate function.

Example:
  (core-registry-find-by-mode eglot-registry \\='python-mode
    (lambda (e) (not (plist-get (nthcdr 3 e) :disabled))))"
 (let ((result nil))
   (catch
    'found
    (dolist
     (entry registry)
     (when
      (or (null filter-fn) (funcall filter-fn entry))
      (let ((modes (nth 2 entry)))
        (when
         (core-registry-mode-compatible-p modes mode) (throw 'found (setq result (car entry))))))))
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
       (when (core-registry-mode-compatible-p modes mode) (push (car entry) results)))))
   (nreverse results)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Iteration Helpers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 registry--map-entries (registry function)
 "Apply FUNCTION to each entry in REGISTRY, return list of results.
FUNCTION receives the full entry and should return a value.
REGISTRY is the registry to iterate over.
FUNCTION is the mapping function.

Example:
  (registry--map-entries reg
    (lambda (entry) (list (car entry) (nth 1 entry))))"
 (mapcar function registry))

(defun
 registry--filter-entries (registry predicate)
 "Return entries from REGISTRY where PREDICATE return non-nil.
PREDICATE receives the full entry.
REGISTRY is the registry to filter.
PREDICATE is the filter function.

Example:
  (registry--filter-entries reg
    (lambda (e) (eq (plist-get (nthcdr 3 e) :type) \\='lsp)))"
 (cl-remove-if-not predicate registry))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Filtering Helpers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 core-registry-filter-disabled (registry identifier-list)
 "Filter IDENTIFIER-LIST, removing entries marked as disabled in REGISTRY.
Return new list with disabled entries removed.
Only filters symbol identifiers; preserves non-symbol elements unchanged.

REGISTRY is the registry to check for :disabled flags.
IDENTIFIER-LIST is list of identifiers to filter.

This function checks each symbol identifier against REGISTRY and removes
those with :disabled t property.  Non-symbol elements (like hook markers)
are preserved in the output.

Example:
  (core-registry-filter-disabled
    flymake-backend-registry
    \\='(python-flymake sh-shellcheck-flymake t \\='elisp-flymake-byte-compile))
  => (python-flymake t \\='elisp-flymake-byte-compile)
  ;; Removes sh-shellcheck-flymake if :disabled t in registry"
 (cl-remove-if
  (lambda
   (identifier)
   (when
    (symbolp identifier)
    (let* ((entry (core-registry-find-entry registry identifier))
           (props (when entry (nthcdr 3 entry)))
           (disabled (when props (plist-get props :disabled))))
      disabled)))
  identifier-list))

(provide 'core-registry-query)
;;; core-registry-query.el ends here
