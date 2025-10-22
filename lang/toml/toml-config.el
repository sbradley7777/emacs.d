;;; toml-config.el --- TOML Language Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      TOML mode support and configuration for .toml files including pyproject.toml.
;;      Supports both toml-mode and toml-ts-mode with shared configuration.
(require 'core-utils)
(require 'core-logging)
(require 'core-constants)
(core-utils-with-load-timing
 "toml-config.el"
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Shared Configuration Function
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  toml-setup-common
  ()
  "Common setup for both toml-mode and toml-ts-mode."
  (setq indent-tabs-mode nil)
  (setq tab-width core-tab-width)
  (electric-indent-mode 1))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; TOML Mode Configuration
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (require 'toml-mode)

 ;; File associations (treesit-auto overrides when grammar available)
 (add-to-list 'auto-mode-alist '("\\.toml\\'" . toml-mode))
 (add-to-list 'auto-mode-alist '("pyproject\\.toml\\'" . toml-mode))
 (add-to-list 'auto-mode-alist '("Cargo\\.toml\\'" . toml-mode))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Mode Hooks - Apply to both toml-mode and toml-ts-mode
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Apply common setup to toml-mode
 (add-hook 'toml-mode-hook #'toml-setup-common)

 ;; Apply common setup to toml-ts-mode (when tree-sitter grammar available)
 (add-hook 'toml-ts-mode-hook #'toml-setup-common)

 (core-message-success "TOML configuration loaded (toml-mode and toml-ts-mode)"))
(provide 'toml-config)
