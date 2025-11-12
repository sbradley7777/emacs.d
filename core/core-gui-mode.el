;;; core-gui-mode.el --- GUI Mode Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      GUI mode settings, UI elements control, and window management setup.

;;; Code:
(require 'core-utils)
(require 'core-logging)
(core-utils-with-load-timing
 "core-gui-mode.el"

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
 ;; macOS Native Fullscreen Configuration
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Use macOS native fullscreen instead of fighting display refresh
 (when
  (eq system-type 'darwin)
  ;; Enable native fullscreen support for macOS
  (setq ns-use-native-fullscreen t)
  ;; Ensure proper frame parameters for fullscreen
  (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
  (add-to-list 'default-frame-alist '(ns-appearance . dark))
  (core-message-info "macOS native fullscreen enabled"))

 ;; Make this module available for loading with (require 'core-gui-mode)
 )
(provide 'core-gui-mode)
;;; core-gui-mode.el ends here
