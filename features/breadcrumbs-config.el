;;; breadcrumbs-config.el --- Breadcrumb Navigation Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Configuration for breadcrumb navigation mode.
;;      Provides hierarchical navigation showing file path and code structure.

(require 'core-constants)
(require 'core-utils)

(core-utils-with-load-timing
 "breadcrumbs-config.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Breadcrumb Navigation
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (use-package
  breadcrumb
  :ensure t
  :config (breadcrumb-mode 1)
  ;; Customize breadcrumb colors for better terminal readability
  (set-face-attribute 'breadcrumb-face nil :foreground "cyan")
  (set-face-attribute 'breadcrumb-project-base-face nil :foreground "brightyellow" :weight 'bold)
  (set-face-attribute 'breadcrumb-project-crumbs-face nil :foreground "yellow")
  (set-face-attribute 'breadcrumb-project-leaf-face nil :foreground "brightcyan" :weight 'bold)
  (set-face-attribute 'breadcrumb-imenu-crumbs-face nil :foreground "brightgreen")
  (set-face-attribute 'breadcrumb-imenu-leaf-face nil :foreground "brightgreen" :weight 'bold)))

(provide 'breadcrumbs-config)
