;;; flymake-config.el --- Flymake Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Global Flymake configuration for diagnostic display and behavior

(require 'features-constants)
(require 'core-utils)

(core-utils-with-load-timing
 "flymake-config.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Flymake Display Configuration
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Configure Flymake diagnostics to display in side window instead of bottom
 (add-to-list
  'display-buffer-alist
  '("\\*Flymake diagnostics.*\\*"
    (display-buffer-in-side-window)
    (side . right)
    (window-parameters . ((no-delete-other-windows . t) (no-other-window . nil)))))

 (setq syntax-checking-window-width features-window-width-percentage)

 ;; Make this module available for loading with (require 'flymake-config)
 (provide 'flymake-config))
