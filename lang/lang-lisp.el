;;; lang-lisp.el --- Emacs Lisp Language Configuration
;;; Commentary:
;;      Emacs Lisp specific settings and formatting

(message "Loading lang-lisp.el...")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Emacs Lisp indentation and formatting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Function to convert tabs to spaces in buffer
(defun untabify-buffer ()
  "Convert all tabs to spaces in the current buffer."
  (untabify (point-min) (point-max)))

;; Add hook to convert tabs to spaces when saving Emacs Lisp files
(add-hook 'emacs-lisp-mode-hook
          (lambda ()
            (add-hook 'before-save-hook 'untabify-buffer nil t)))

;; Make this module available for loading with (require 'lang-lisp)
(provide 'lang-lisp)
(message "lang-lisp.el loaded successfully.")
