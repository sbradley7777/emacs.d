;;; gui-mode.el --- GUI Mode Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      GUI mode settings, UI elements control, and window management setup.

(require 'core-constants)
(require 'core-utils)
(require 'gui-mode-functions)

(core-utils-with-load-timing
 "gui-mode.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Frame Parameter Configuration
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Disable GUI elements in default-frame-alist to prevent them from appearing
 ;; even briefly during startup (eliminates the "flash" effect)
 ;; Consolidated GUI element suppression (single operation for better performance)
 (setq
  default-frame-alist
  (append
   default-frame-alist
   '((tool-bar-lines . 0)
     (menu-bar-lines . 0)
     (vertical-scroll-bars . nil)
     (horizontal-scroll-bars . nil))))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; GUI Elements Control
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Conditional UI settings based on display type
 (if
  (display-graphic-p)
  ;; For GUI frames, enable menu and scroll bar but disable tool bar
  (progn (menu-bar-mode 1) (tool-bar-mode -1) (scroll-bar-mode 1))
  ;; For terminal frames, disable the menu bar. Tool and scroll bars are graphical-only and don't exist in terminals.
  (menu-bar-mode -1))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Window State Management Hook Registration
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (add-hook 'window-size-change-functions 'ui-auto-refresh)
 (add-hook 'window-state-change-hook 'ui-auto-refresh)
 (add-hook 'focus-in-hook 'ui-auto-refresh)

 ;; Make this module available for loading with (require 'gui-mode)
 (provide 'gui-mode))
