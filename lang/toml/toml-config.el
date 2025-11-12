;;; toml-config.el --- TOML Language Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      TOML mode support and configuration for .toml files including pyproject.toml.
;;      Supports both toml-mode and toml-ts-mode with shared configuration.

;;; Code:
(require 'core-utils)
(require 'core-logging)
(require 'core-constants)
(require 'lang-utils)
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
 (lang-register-file-extensions 'toml-mode "\\.toml\\'" "pyproject\\.toml\\'" "Cargo\\.toml\\'")

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Mode Hooks - Apply to both toml-mode and toml-ts-mode
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (lang-add-dual-mode-hooks 'toml-mode-hook 'toml-ts-mode-hook #'toml-setup-common)

 (core-message-success "TOML configuration loaded (toml-mode and toml-ts-mode)"))
(provide 'toml-config)
;;; toml-config.el ends here
