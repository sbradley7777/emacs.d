;;; breadcrumbs-config.el --- Breadcrumb Navigation Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Configuration for breadcrumb navigation mode.
;;      Provides hierarchical navigation showing file path and code structure.

(require 'core-constants)
(require 'core-utils)

(core-utils-with-load-timing
 "breadcrumbs-config.el"
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Breadcrumb Navigation
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (use-package
  breadcrumb
  :ensure t
  :config (breadcrumb-mode 1)
  ;; Note: Theme-specific breadcrumb colors are applied by each theme's setup function
  ;; (e.g., doom-1337-breadcrumb-faces-apply in theme-doom-1337.el)
  ;; This ensures breadcrumb colors always match the active theme's modeline colors
  ))

(provide 'breadcrumbs-config)
