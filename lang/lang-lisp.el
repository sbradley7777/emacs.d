;;; lang-lisp.el --- Emacs Lisp Language Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Emacs Lisp specific settings and formatting

(defvar config-load-start-time (current-time))
(message "Loading lang-lisp.el...")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Emacs Lisp indentation and formatting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Function to convert tabs to spaces in buffer
(defun untabify-buffer ()
  "Convert all tabs to spaces in the current buffer."
  (untabify (point-min) (point-max)))

;; Add hook to convert tabs to spaces when saving Emacs Lisp files
(add-hook 'emacs-lisp-mode-hook (lambda () (add-hook 'before-save-hook 'untabify-buffer nil t)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Automatic formatting with elisp-autofmt
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package
 elisp-autofmt
 :hook (emacs-lisp-mode . elisp-autofmt-mode)
 :bind (:map emacs-lisp-mode-map ("C-c C-f" . elisp-autofmt-buffer))
 :config (message "elisp-autofmt configured for automatic formatting on save"))

;; Make this module available for loading with (require 'lang-lisp)
(provide 'lang-lisp)
(message "lang-lisp.el loaded (%.2fs)" (float-time (time-subtract (current-time) config-load-start-time)))
