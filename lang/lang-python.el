;;; lang-python.el --- Python Language Configuration
;;; Commentary:
;;      Python and Elpy configuration

(message "Loading lang-python.el...")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Python-specific indentation settings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-hook 'python-mode-hook
          (lambda ()
            (setq python-indent-guess-indent-offset t) ; python-indent-guess-indent-offset. When set to a non-nil value, it attempts to guess the indentation offset based on the existing indentation in the file.
            (setq indent-tabs-mode nil) ; Use spaces
            (setq python-indent 4)))   ; 4 spaces for indentation

(provide 'lang-python)
(message "lang-python.el loaded successfully.")
