;;; lisp-config.el --- Emacs Lisp Language Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Emacs Lisp specific settings and formatting

(require 'core-utils)
(require 'core-logging)

(core-utils-with-load-timing
 "lisp-config.el"
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Emacs Lisp indentation and formatting
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Function to convert tabs to spaces in buffer
 (defun
  lisp-config-untabify-buffer
  ()
  "Convert all tabs to spaces in the current buffer."
  (untabify (point-min) (point-max)))

 ;; Add hook to convert tabs to spaces when saving Emacs Lisp files
 (add-hook
  'emacs-lisp-mode-hook
  (lambda () (add-hook 'before-save-hook #'lisp-config-untabify-buffer nil t)))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Automatic formatting with elisp-autofmt
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (use-package
  elisp-autofmt
  :hook (emacs-lisp-mode . elisp-autofmt-mode)
  :bind (:map emacs-lisp-mode-map ("C-c C-f" . elisp-autofmt-buffer))
  :config (core-message-config "elisp-autofmt configured for automatic formatting on save")))

(provide 'lisp-config)
