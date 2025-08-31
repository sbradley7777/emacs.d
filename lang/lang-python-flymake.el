;;; lang-python-flymake.el --- Python Flymake Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Flymake configuration specific to Python development

(defvar config-load-start-time (current-time))
(message "Loading lang-python-flymake.el...")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Flymake Display Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Configure Flymake diagnostics to display in side window instead of bottom
(add-to-list 'display-buffer-alist
             '("\\*Flymake diagnostics.*\\*"
               (display-buffer-in-side-window)
               (side . right)
               (window-width . 100)
               (window-parameters . ((no-delete-other-windows . t)
                                     (no-other-window . nil)))))

;; Make this module available for loading with (require 'lang-python-flymake)
(provide 'lang-python-flymake)
(message "lang-python-flymake.el loaded (%.2fs)" (float-time (time-subtract (current-time) config-load-start-time)))
