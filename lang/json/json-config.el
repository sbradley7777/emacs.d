;;; json-config.el --- JSON Language Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      JSON mode support and configuration.
;;      Supports both json-mode and json-ts-mode with shared configuration.

(require 'core-utils)
(require 'core-logging)

(core-utils-with-load-timing
 "json-config.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Shared Configuration Function
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (defun
  json-setup-common
  ()
  "Common setup for both json-mode and json-ts-mode."
  (setq indent-tabs-mode nil)
  (setq js-indent-level 2)
  (electric-indent-mode 1))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; JSON Mode Configuration
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;; File associations (treesit-auto will override when json grammar available)
 (add-to-list 'auto-mode-alist '("\\.json\\'" . json-mode))
 (add-to-list 'auto-mode-alist '("\\.jsonc\\'" . json-mode))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Mode Hooks - Apply to both json-mode and json-ts-mode
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;; Apply common setup to json-mode
 (add-hook 'json-mode-hook 'json-setup-common)

 ;; Apply common setup to json-ts-mode (when tree-sitter grammar available)
 (add-hook 'json-ts-mode-hook 'json-setup-common)

 (core-message-success "JSON configuration loaded (json-mode and json-ts-mode)"))

(provide 'json-config)

;;; json-config.el ends here
