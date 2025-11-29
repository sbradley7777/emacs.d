;;; core-registry-constructors.el --- Registry Entry Constructors -*- lexical-binding: t -*-
;;; Commentary:
;; Constructor functions for building registry entries.
;;
;; Base constructor:
;;   core-registry-create-base-entry - Create entry with common properties
;;
;; Helper functions:
;;   core-registry-merge-properties  - Merge property plists
;;
;; Common properties (all registries):
;;   :binary          - Executable name
;;   :disabled        - Skip this entry
;;   :disabled-reason - Why disabled
;;   :priority        - Integer priority (default 100, lower = higher priority)
;;   :url             - Project homepage URL
;;
;; Usage pattern:
;;   Domain-specific constructors call core-registry-create-base-entry
;;   and extend with additional properties.
;;
;; Example:
;;   (defun my-registry-create-entry (id desc modes &key binary my-prop)
;;     (let* ((base (core-registry-create-base-entry id desc modes :binary binary))
;;            (base-props (nthcdr 3 base))
;;            (my-props (list :my-prop my-prop)))
;;       (append (list id desc modes)
;;               (core-registry-merge-properties base-props my-props))))

;;; Code:
(require 'cl-lib)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Base Constructor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(cl-defun
 core-registry-create-base-entry
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
  (core-registry-create-base-entry
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
(defun
 core-registry-merge-properties (base-props extension-props)
 "Merge BASE-PROPS and EXTENSION-PROPS plists.
EXTENSION-PROPS take precedence over BASE-PROPS for duplicate keys.

BASE-PROPS typically come from base constructor (common properties).
EXTENSION-PROPS come from domain-specific constructor (unique properties).

Example:
  (core-registry-merge-properties
   \\='(:binary \"foo\" :disabled nil)
   \\='(:abbreviation \"f\" :type \\='direct))
  => (:binary \"foo\" :disabled nil :abbreviation \"f\" :type direct)"
 (let ((merged (copy-sequence base-props)))
   (cl-loop for (key val) on extension-props by #'cddr do (setq merged (plist-put merged key val)))
   merged))

(provide 'core-registry-constructors)
;;; core-registry-constructors.el ends here
