;;; json-config.el --- JSON Language Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      JSON mode support and configuration.
;;      Supports both js-json-mode (built-in) and json-ts-mode with shared configuration.
;;      tree-sit-auto handles automatic grammar installation and mode switching.

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
  "Common setup for both js-json-mode and json-ts-mode."
  (setq indent-tabs-mode nil)
  (setq js-indent-level 2)
  (electric-indent-mode 1))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; JSON Mode Configuration
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;; NOTE: Do not set auto-mode-alist here for .json files
 ;; treesit-auto expects js-json-mode (built-in) to activate first, then it will:
 ;; 1. Prompt to install json grammar if missing
 ;; 2. Switch to json-ts-mode if grammar is installed
 ;; Adding json-mode to auto-mode-alist prevents treesit-auto from detecting and prompting

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Mode Hooks
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;; Apply common setup to js-json-mode (built-in fallback when grammar not installed)
 (add-hook 'js-json-mode-hook 'json-setup-common)

 ;; Apply common setup to json-ts-mode (when tree-sitter grammar available)
 (add-hook 'json-ts-mode-hook 'json-setup-common)

 (core-message-success "JSON configuration loaded (js-json-mode and json-ts-mode)"))

(provide 'json-config)

;;; json-config.el ends here
