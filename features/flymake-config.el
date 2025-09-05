;;; flymake-config.el --- Flymake Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Global Flymake configuration for diagnostic display and behavior

(require 'features-constants)
(require 'utils)

(with-load-timing
 "flymake-config.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Flymake Display Configuration
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Configure Flymake diagnostics to display in side window instead of bottom
 (add-to-list
  'display-buffer-alist
  '("\\*Flymake diagnostics.*\\*"
    (display-buffer-in-side-window)
    (side . right)
    (window-width . ,features-flymake-window-width)
    (window-parameters . ((no-delete-other-windows . t) (no-other-window . nil)))))

 ;; Make this module available for loading with (require 'flymake-config)
 (provide 'flymake-config))
