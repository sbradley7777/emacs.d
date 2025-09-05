;;; yaml-config.el --- YAML Language Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      YAML mode support and configuration

(require 'utils)

(with-load-timing
 "yaml-config.el"
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Load yaml mode support
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (require 'yaml-mode)
 (add-to-list 'auto-mode-alist '("\\.ya?ml\\'" . yaml-mode)) ; Support both .yml and .yaml files
 (add-hook 'yaml-mode-hook (lambda () (define-key yaml-mode-map "\C-m" 'newline-and-indent)))

 ;; Make this module available for loading with (require 'yaml-config)
 (provide 'yaml-config))
