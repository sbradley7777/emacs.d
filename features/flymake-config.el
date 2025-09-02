;;; flymake-config.el --- Flymake Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Global Flymake configuration for diagnostic display and behavior

(defvar config-load-start-time (current-time))
(message "Loading flymake-config.el...")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Flymake Display Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Configure Flymake diagnostics to display in side window instead of bottom
(add-to-list
 'display-buffer-alist
 '("\\*Flymake diagnostics.*\\*"
   (display-buffer-in-side-window)
   (side . right)
   (window-width . 100)
   (window-parameters . ((no-delete-other-windows . t) (no-other-window . nil)))))

;; Make this module available for loading with (require 'flymake-config)
(provide 'flymake-config)
(message
 "flymake-config.el loaded (%.2fs)"
 (float-time (time-subtract (current-time) config-load-start-time)))
