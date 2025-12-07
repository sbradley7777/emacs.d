;;; registry-validation.el --- Registry Validation Functions -*- lexical-binding: t -*-
;;; Commentary:
;; Runtime validation functions for registry entries.
;;
;; Validation functions:
;;   - registry-mode-compatible-p    - Check mode compatibility
;;   - registry-entry-enabled-p      - Check if entry is enabled (not disabled)
;;
;; All structure and type validation is performed by registry-create-entry
;; at creation time. Runtime only checks the :disabled flag.

;;; Code:
(require 'cl-lib)

;; Forward declarations
(declare-function registry-get-property "registry-query")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Mode Compatibility
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 registry-mode-compatible-p (supported-modes current-mode)
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
;; Entry Availability
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 registry-entry-enabled-p (registry identifier)
 "Check if IDENTIFIER in REGISTRY is enabled.
Return non-nil if entry is not disabled, nil otherwise.

All validation (structure, type, binary existence) is performed by the constructor
at creation time. This function only checks the :disabled flag set by the constructor.

REGISTRY is the registry to check.
IDENTIFIER is the entry identifier symbol to look up.

Example:
  (registry-entry-enabled-p flymake-backend-registry \\='python-flymake)
  (registry-entry-enabled-p eglot-lsp-server-registry \\='pylsp)"
 (not (registry-get-property registry identifier :disabled)))

(defun
 registry-entry-defer-check-p (registry identifier)
 "Check if IDENTIFIER in REGISTRY should defer Flymake checks.
Return t if entry has :defer-check property set to t, nil otherwise.

This is used to control whether a Flymake backend should defer its initial
check until LSP connects, avoiding \\='Canceling obsolete check\\=' warnings in
dual-backend scenarios.

REGISTRY is the registry to check.
IDENTIFIER is the entry identifier symbol to look up.

Example:
  (registry-entry-defer-check-p flymake-backend-registry \\='flymake-collection-yamllint)
  => t
  (registry-entry-defer-check-p flymake-backend-registry \\='flymake-shellcheck-load)
  => nil"
 (eq (registry-get-property registry identifier :defer-check) t))

(provide 'registry-validation)
;;; registry-validation.el ends here
