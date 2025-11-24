;;; yaml-config.el --- YAML Language Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      YAML mode support and configuration.
;;      Supports both yaml-mode and yaml-ts-mode with shared configuration.

;;; Code:
(require 'core-utils)
(require 'core-logging)
(require 'lang-utils)

;; External declarations
(declare-function flymake-collection-yamllint "flymake-collection")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 yaml-flymake-setup ()
 "Enable yamllint checker for YAML files via flymake-collection.
Uses flymake-collection-yamllint backend if yamllint is available in PATH."
 (when
  (and (executable-find "yamllint") (fboundp 'flymake-collection-yamllint))
  (add-hook 'flymake-diagnostic-functions 'flymake-collection-yamllint nil t)))

(defun
 yaml-setup-common
 ()
 "Common setup for both `yaml-mode' and yaml-ts-mode."
 (lang-setup-minimal 'yaml-indent-offset 2)
 (local-set-key (kbd "C-m") 'newline-and-indent)
 (yaml-flymake-setup)
 (flymake-mode 1)
 (when
  (boundp 'flymake-config--check-timer)
  (when flymake-config--check-timer (cancel-timer flymake-config--check-timer))
  (setq flymake-config--check-timer (run-with-timer 3.0 nil #'flymake-config--check-all-buffers))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; YAML Mode Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'yaml-mode)

;; File associations (treesit-auto overrides when grammar available)
(add-to-list 'auto-mode-alist '("\\.ya?ml\\'" . yaml-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Mode Hooks - Apply to both yaml-mode and yaml-ts-mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(lang-register-dual-mode-hooks yaml yaml-setup-common)

(core-message-success "YAML configuration loaded (yaml-mode and yaml-ts-mode)")
(provide 'yaml-config)
;;; yaml-config.el ends here
