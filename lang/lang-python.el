;;; lang-python.el --- Python Language Configuration
;;; Commentary:
;; Python and Elpy configuration
;;; Code:

(message "Loading lang-python.el...")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Enable elpy.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq python-shell-interpreter "/usr/bin/python3")
(setq elpy-rpc-python-command "/usr/bin/python3")
(elpy-enable)
;; use flycheck, not flymake with elpy
(when (require 'flycheck nil t)
  (setq elpy-modules (delq 'elpy-module-flymake elpy-modules))
  (add-hook 'elpy-mode-hook 'flycheck-mode)
  (flycheck-add-next-checker 'python-flake8 'python-pylint))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Python-specific indentation settings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-hook 'python-mode-hook
          (lambda ()
            (setq python-indent-guess-indent-offset t) ; python-indent-guess-indent-offset. When set to a non-nil value, it attempts to guess the indentation offset based on the existing indentation in the file.
            (setq indent-tabs-mode nil) ; Use spaces
            (setq python-indent 4)))   ; 4 spaces for indentation

(message "lang-python.el loaded successfully.")
(provide 'lang-python)
;;; lang-python.el ends here
