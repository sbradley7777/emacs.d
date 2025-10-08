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
  ;; Customize breadcrumb colors to match doom-1337 modeline theme
  (set-face-attribute 'breadcrumb-face nil :foreground "#00ff9f") ; Cyan - matches general nav
  (set-face-attribute 'breadcrumb-project-base-face nil :foreground "#00b8ff" :weight 'bold) ; Blue - matches project-dir
  (set-face-attribute 'breadcrumb-project-crumbs-face nil :foreground "#7bc275") ; Green - matches buffer-path
  (set-face-attribute 'breadcrumb-project-leaf-face nil :foreground "#00ff9f" :weight 'bold) ; Cyan - matches buffer-file
  (set-face-attribute 'breadcrumb-imenu-crumbs-face nil :foreground "#7bc275") ; Green - code structure path
  (set-face-attribute 'breadcrumb-imenu-leaf-face nil :foreground "#00ff9f" :weight 'bold))) ; Cyan - current symbol

(provide 'breadcrumbs-config)
