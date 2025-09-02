;;; lang-yaml.el --- YAML Language Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      YAML mode support and configuration

(defvar config-load-start-time (current-time))
(message "Loading lang-yaml.el...")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load yaml mode support
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'yaml-mode)
(add-to-list 'auto-mode-alist '("\\.ya?ml\\'" . yaml-mode)) ; Support both .yml and .yaml files
(add-hook 'yaml-mode-hook (lambda () (define-key yaml-mode-map "\C-m" 'newline-and-indent)))

;; Make this module available for loading with (require 'lang-yaml)
(provide 'yaml)
(message
 "lang-yaml.el loaded (%.2fs)" (float-time (time-subtract (current-time) config-load-start-time)))
