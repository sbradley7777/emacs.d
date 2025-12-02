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
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 modeline-faces-apply-for-theme (theme)
 "Apply modeline face customizations for THEME if available.
THEME should be a symbol like \\='doom-1337 or \\='doom-zenburn."
 (let ((theme-name (symbol-name theme)))
   (cond
    ((string= theme-name "doom-1337")
     (require 'theme-doom-1337)
     (themes-doom-1337-modeline-faces-apply))
    (t
     (core-message-debug "No custom modeline faces defined for theme: %s" theme-name)))))

(defun
 modeline--faces-on-theme-change (&rest _) "Apply modeline faces when theme change."
 (when
  (and (boundp 'themes-config-preferred-theme) (featurep 'doom-modeline))
  (modeline-faces-apply-for-theme themes-config-preferred-theme)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(with-eval-after-load
 'doom-modeline
 (when
  (boundp 'themes-config-preferred-theme)
  (modeline-faces-apply-for-theme themes-config-preferred-theme)))

(add-hook 'after-load-theme-hook #'modeline--faces-on-theme-change)
(provide 'modeline-faces)
;;; modeline-faces.el ends here
