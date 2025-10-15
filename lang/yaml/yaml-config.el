;;; yaml-config.el --- YAML Language Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      YAML mode support and configuration.
;;      Supports both yaml-mode and yaml-ts-mode with shared configuration.

(require 'core-utils)
(require 'core-logging)

(core-utils-with-load-timing
 "yaml-config.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Shared Configuration Function
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (defun
  yaml-setup-common
  ()
  "Common setup for both yaml-mode and yaml-ts-mode."
  (setq indent-tabs-mode nil)
  (setq yaml-indent-offset 2)
  (electric-indent-mode 1)
  (local-set-key (kbd "C-m") 'newline-and-indent))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; YAML Mode Configuration
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (require 'yaml-mode)

 ;; File associations (treesit-auto overrides when grammar available)
 (add-to-list 'auto-mode-alist '("\\.ya?ml\\'" . yaml-mode))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Mode Hooks - Apply to both yaml-mode and yaml-ts-mode
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;; Apply common setup to yaml-mode
 (add-hook 'yaml-mode-hook 'yaml-setup-common)

 ;; Apply common setup to yaml-ts-mode (when tree-sitter grammar available)
 (add-hook 'yaml-ts-mode-hook 'yaml-setup-common)

 (core-message-success "YAML configuration loaded (yaml-mode and yaml-ts-mode)"))

(provide 'yaml-config)
