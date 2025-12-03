;;; lisp-config.el --- Emacs Lisp Language Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Emacs Lisp specific settings and formatting

;;; Code:
(require 'core-utils)
(require 'core-logging)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Automatic formatting with elisp-autofmt
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package
 elisp-autofmt
 :hook (emacs-lisp-mode . elisp-autofmt-mode)
 :bind (:map emacs-lisp-mode-map ("C-c C-f" . elisp-autofmt-buffer))
 :config (logging-config "elisp-autofmt configured for automatic formatting on save"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 lisp--config-untabify-buffer
 ()
 "Convert all tabs to spaces in the current buffer."
 (untabify (point-min) (point-max)))

;; Add hook to convert tabs to spaces when saving Emacs Lisp files
(add-hook
 'emacs-lisp-mode-hook
 (lambda () (add-hook 'before-save-hook #'lisp--config-untabify-buffer nil t)))
(provide 'lisp-config)
;;; lisp-config.el ends here
