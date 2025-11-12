;;; flymake-config.el --- Flymake Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Global Flymake configuration for diagnostic display and behavior

;;; Code:
(require 'core-utils)
(require 'features-constants)
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
    (window-parameters . ((no-delete-other-windows . t) (no-other-window . nil))))))
(provide 'flymake-config)
;;; flymake-config.el ends here
