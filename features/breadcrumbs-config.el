;;; breadcrumbs-config.el --- Breadcrumb Navigation Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Configuration for breadcrumb navigation mode.
;;      Provides hierarchical navigation showing file path and code structure.

;;; Code:
(require 'core-constants)

;; Declare external variables to suppress byte-compiler warnings
(defvar breadcrumb) ; From breadcrumb.el

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Breadcrumb Navigation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package
 breadcrumb
 :ensure t
 :config (breadcrumb-mode 1)
 ;; Note: Theme-specific breadcrumb colors are applied by each theme's setup function
 ;; (e.g., doom-1337-breadcrumb-faces-apply in theme-doom-1337.el)
 ;; This ensures breadcrumb colors always match the active theme's modeline colors
 )
(provide 'breadcrumbs-config)
;;; breadcrumbs-config.el ends here
