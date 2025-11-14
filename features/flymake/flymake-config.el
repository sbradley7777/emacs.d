;;; flymake-config.el --- Flymake Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Global Flymake configuration for diagnostic display and behavior

;;; Code:
(require 'core-utils)
(require 'features-constants)

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Enable Flymake for Programming Modes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Enable Flymake automatically for all programming modes (Python, Emacs Lisp, C, etc.)
;; Each mode uses its own built-in or configured backends (e.g., ruff for Python, checkdoc for Elisp)
;; Skip *scratch* buffer to avoid triggering Emacs security warnings about untrusted content
(defun
 flymake-config--enable-for-prog-mode
 ()
 "Enable Flymake mode for programming buffers, excluding *scratch*."
 (unless (string= (buffer-name) "*scratch*") (flymake-mode 1)))
(add-hook 'prog-mode-hook 'flymake-config--enable-for-prog-mode)
(provide 'flymake-config)
;;; flymake-config.el ends here
