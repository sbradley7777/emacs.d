;;; lang-yaml.el --- YAML Language Configuration
;;; Commentary:
;;      YAML mode support and configuration

(message "Loading lang-yaml.el...")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load yaml mode support
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(message "Requiring yaml-mode.")
(require 'yaml-mode)
(add-to-list 'auto-mode-alist '("\\.yml\\'" . yaml-mode))
(add-to-list 'auto-mode-alist '("\\.yaml\\'" . yaml-mode))
(add-hook 'yaml-mode-hook
	  #'(lambda ()
	      (define-key yaml-mode-map "\C-m" 'newline-and-indent)))

(provide 'lang-yaml)
(message "lang-yaml.el loaded successfully.")
