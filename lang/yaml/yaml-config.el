;;; yaml-config.el --- YAML Language Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      YAML mode support and configuration.
;;      Supports both yaml-mode and yaml-ts-mode with shared configuration.

;;; Code:
(require 'core-utils)
(require 'core-logging)
(require 'lang-utils)
(core-utils-with-load-timing
 "yaml-config.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Shared Configuration Function
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  yaml-setup-common
  ()
  "Common setup for both yaml-mode and yaml-ts-mode."
  (lang-setup-minimal 'yaml-indent-offset 2)
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
 (lang-register-dual-mode-hooks yaml yaml-setup-common)

 (core-message-success "YAML configuration loaded (yaml-mode and yaml-ts-mode)"))
(provide 'yaml-config)
;;; yaml-config.el ends here
