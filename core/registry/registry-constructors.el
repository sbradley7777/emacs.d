;;; registry-constructors.el --- Registry Entry Constructors -*- lexical-binding: t -*-
;;; Commentary:
;; Constructor functions for building registry entries.
;;
;; Base constructor:
;;   registry-create-base-entry - Create entry with common properties
;;
;; Helper functions:
;;   registry-merge-properties  - Merge property plists
;;
;; Common properties (all registries):
;;   :binary          - Executable name
;;   :disabled        - Skip this entry
;;   :disabled-reason - Why disabled
;;   :priority        - Integer priority (default 100, lower = higher priority)
;;   :url             - Project homepage URL
;;
;; Usage pattern:
;;   Domain-specific constructors call registry-create-base-entry
;;   and extend with additional properties.
;;
;; Example:
;;   (defun registry--my-create-entry (id desc modes &key binary my-prop)
;;     (let* ((base (registry-create-base-entry id desc modes :binary binary))
;;            (base-props (nthcdr 3 base))
;;            (my-props (list :my-prop my-prop)))
;;       (append (list id desc modes)
;;               (registry-merge-properties base-props my-props))))

;;; Code:
(require 'cl-lib)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Base Constructor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(cl-defun
 registry-create-base-entry
 (identifier description modes &key binary disabled disabled-reason (priority 100) url)
 "Create base registry entry with common properties.

All registry entries share these properties:

Required parameters:
  IDENTIFIER   - Symbol uniquely identifying this entry
  DESCRIPTION  - User-friendly description string
  MODES        - List of major mode symbols (or special value like (multiple))

Common optional keywords:
  :binary          - Executable name (e.g., \"pylsp\", \"shellcheck\")
  :disabled        - If t, skip this entry during setup
  :disabled-reason - Explanation for why entry is disabled
  :priority        - Integer priority for overlapping modes (default 100, lower = higher)
  :url             - Project homepage URL

Returns entry in format: (IDENTIFIER DESCRIPTION MODES . BASE-PROPERTIES)
This is meant to be extended by domain-specific constructors.

Example:
  (registry-create-base-entry
   \\='my-backend \"My Backend\" \\='(python-mode)
   :binary \"my-binary\"
   :priority 50
   :url \"https://github.com/example/my-backend\")"
 (unless (symbolp identifier) (error "Registry entry identifier must be symbol: %s" identifier))
 (unless (stringp description) (error "Registry entry description must be string: %s" description))
 (unless (listp modes) (error "Registry entry modes must be list: %s" modes))
 (let ((props nil))
   (when binary (setq props (plist-put props :binary binary)))
   (when disabled (setq props (plist-put props :disabled disabled)))
   (when disabled-reason (setq props (plist-put props :disabled-reason disabled-reason)))
   (setq props (plist-put props :priority priority))
   (when url (setq props (plist-put props :url url)))
   (append (list identifier description modes) props)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Property Helpers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(cl-defun
 registry-create-entry
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
 "Create registry entry with all common and domain-specific properties.

This is the universal constructor used by both flymake and eglot registries.

Required parameters:
  IDENTIFIER   - Symbol uniquely identifying this entry
  DESCRIPTION  - User-friendly description string
  MODES        - List of major mode symbols (or special value like (multiple))

Common properties (inherited from base):
  :binary          - Executable name (e.g., \\\"pylsp\\\", \\\"shellcheck\\\")
  :disabled        - If t, skip this entry during setup
  :disabled-reason - Explanation for why entry is disabled
  :priority        - Integer priority (default 100, lower = higher priority)
  :url             - Project homepage URL

Domain-specific properties:
  :abbreviation - Short identifier for display (e.g., \\\"f-c-y\\\", \\\"pylsp\\\")
  :type         - Entry type: \\='direct, \\='loader-based, or \\='lsp
  :loader       - Function symbol to call for loading (optional)

Type validation:
  If :type is provided, it must be one of: direct, loader-based, lsp

Example:
  (registry-create-entry
   \\='flymake-collection-yamllint \\\"YAMLLint\\\" \\='(yaml-mode yaml-ts-mode)
   :abbreviation \\\"f-c-y\\\"
   :type \\='direct
   :binary \\\"yamllint\\\"
   :url \\\"https://github.com/adrienverge/yamllint\\\")"
 ;; Validate type if provided
 (when
  (and type (not (memq type '(direct loader-based lsp))))
  (error
   "Registry entry %s has invalid :type %s (must be direct, loader-based, or lsp)"
   identifier
   type))
 ;; Auto-disable if binary specified but not found (unless already disabled or built-in)
 (when
  (and
   binary (not disabled) (not (string= binary "(built-in)")) (not (executable-find binary)))
  (setq disabled t) (setq disabled-reason (format "Binary '%s' not found in PATH" binary)))
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
        (ext-props nil))
   ;; Add optional domain properties
   (when abbreviation (setq ext-props (plist-put ext-props :abbreviation abbreviation)))
   (when type (setq ext-props (plist-put ext-props :type type)))
   (when loader (setq ext-props (plist-put ext-props :loader loader)))
   (let ((merged-props (registry-merge-properties base-props ext-props)))
     (append (list identifier description modes) merged-props))))

(defun
 registry-merge-properties (base-props extension-props)
 "Merge BASE-PROPS and EXTENSION-PROPS plists.
EXTENSION-PROPS take precedence over BASE-PROPS for duplicate keys.

BASE-PROPS typically come from base constructor (common properties).
EXTENSION-PROPS come from domain-specific constructor (unique properties).

Example:
  (registry-merge-properties
   \\='(:binary \"foo\" :disabled nil)
   \\='(:abbreviation \"f\" :type \\='direct))
  => (:binary \"foo\" :disabled nil :abbreviation \"f\" :type direct)"
 (let ((merged (copy-sequence base-props)))
   (cl-loop for (key val) on extension-props by #'cddr do (setq merged (plist-put merged key val)))
   merged))

(provide 'registry-constructors)
;;; registry-constructors.el ends here
