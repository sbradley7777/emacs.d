;;; modeline-faces.el --- Generic modeline face dispatcher -*- lexical-binding: t -*-
;;; Commentary:
;;      Generic dispatcher for theme-specific modeline customizations.
;;      Theme-specific faces are defined in theme-*.el files.

;;; Code:
(require 'core-constants)
(require 'core-utils)
(require 'core-logging)
(require 'themes-config)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Face Application Logic
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 modeline-faces-apply-for-theme (theme)
 "Apply modeline face customizations for THEME if available.
THEME should be a symbol like 'doom-1337 or 'doom-zenburn."
 (let ((theme-name (symbol-name theme)))
   (cond
    ((string= theme-name "doom-1337")
     (require 'theme-doom-1337)
     (doom-1337-modeline-faces-apply))
    (t
     (core-message-debug "No custom modeline faces defined for theme: %s" theme-name)))))

;; Apply faces after both doom-modeline AND the theme are loaded
;; This runs when doom-modeline loads, then again when the theme changes
(with-eval-after-load
 'doom-modeline
 (when
  (boundp 'themes-config-preferred-theme)
  (modeline-faces-apply-for-theme themes-config-preferred-theme)))

;; Also hook into theme loading to reapply faces when theme changes
(defun
 modeline-faces--on-theme-change (&rest _) "Apply modeline faces when theme changes."
 (when
  (and (boundp 'themes-config-preferred-theme) (featurep 'doom-modeline))
  (modeline-faces-apply-for-theme themes-config-preferred-theme)))

;; Add to theme load hooks
(add-hook 'after-load-theme-hook #'modeline-faces--on-theme-change)
(provide 'modeline-faces)
;;; modeline-faces.el ends here
