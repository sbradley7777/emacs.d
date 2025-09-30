;;; flymake-config.el --- Flymake Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Global Flymake configuration for diagnostic display and behavior

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
    (window-parameters . ((no-delete-other-windows . t) (no-other-window . nil)))))

 (setq syntax-checking-window-width features-window-width-percentage)

 ;; A toggle to open and close the flymake diagnostic window.
 (defun
  toggle-flymake-diagnostics-window () "Show or hide the Flymake diagnostics window." (interactive)
  ;; Find any window that is displaying a Flymake diagnostics buffer
  (let ((flymake-window
         (cl-find-if
          (lambda
           (window) (string-prefix-p "*Flymake diagnostics" (buffer-name (window-buffer window))))
          (window-list))))
    ;; If such a window exists, close it. Otherwise, open one.
    (if flymake-window (quit-window nil flymake-window) (flymake-show-buffer-diagnostics))))

 ;; Make this module available for loading with (require 'flymake-config)
 (provide 'flymake-config))
