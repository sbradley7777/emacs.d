;;; json-config.el --- JSON Language Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      JSON mode support and configuration.
;;      Supports both js-json-mode (built-in) and json-ts-mode with shared configuration.
;;      tree-sit-auto handles automatic grammar installation and mode switching.

;;; Code:
(require 'core-utils)
(require 'core-logging)
(require 'lang-utils)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 json-setup-common
 ()
 "Common setup for both js-json-mode and json-ts-mode."
 (lang-setup-minimal 'js-indent-level 2))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; JSON Mode Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; NOTE: Do not set auto-mode-alist here for .json files
;; treesit-auto expects js-json-mode (built-in) to activate first, then it will:
;; 1. Prompt to install json grammar if missing
;; 2. Switch to json-ts-mode if grammar is installed
;; Adding json-mode to auto-mode-alist prevents treesit-auto from detecting and prompting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Mode Hooks
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(lang-add-dual-mode-hooks 'js-json-mode-hook 'json-ts-mode-hook #'json-setup-common)

(core-message-success "JSON configuration loaded (js-json-mode and json-ts-mode)")
(provide 'json-config)
;;; json-config.el ends here
