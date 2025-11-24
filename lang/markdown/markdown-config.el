;;; markdown-config.el --- Markdown Language Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Markdown mode support and configuration for .md files.
;;      Supports both markdown-mode and markdown-ts-mode with shared configuration.

;;; Code:
(require 'core-utils)
(require 'core-logging)
(require 'core-constants)
(require 'lang-utils)

;; External declarations
(declare-function flymake-collection-markdownlint "flymake-collection")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 markdown-flymake-setup ()
 "Enable markdownlint checker for Markdown files via flymake-collection.
Uses flymake-collection-markdownlint backend if mdl is available in PATH."
 (when
  (and (executable-find "mdl") (fboundp 'flymake-collection-markdownlint))
  (add-hook 'flymake-diagnostic-functions 'flymake-collection-markdownlint nil t)))

(defun
 markdown-setup-common
 ()
 "Common setup for both markdown-mode and markdown-ts-mode."
 (lang-setup-minimal 'tab-width core-tab-width)
 (setq markdown-indent-on-enter 'indent-and-new-item)
 (setq markdown-enable-math t)
 (setq markdown-fontify-code-blocks-natively t)
 (visual-line-mode 1)
 (setq fill-column core-fill-column)
 (markdown-flymake-setup)
 (flymake-mode 1)
 (when
  (boundp 'flymake-config--check-timer)
  (when flymake-config--check-timer (cancel-timer flymake-config--check-timer))
  (setq flymake-config--check-timer (run-with-timer 3.0 nil #'flymake-config--check-all-buffers))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Markdown Mode Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'markdown-mode)

;; File associations (treesit-auto overrides when grammar available)
(lang-register-file-extensions 'markdown-mode "\\.md\\'" "\\.markdown\\'" "README\\.md\\'")

;; Terminal-friendly settings (no external preview dependencies)
(with-eval-after-load
 'markdown-mode
 ;; Disable live preview by default (terminal-friendly)
 (setq markdown-live-preview-engine nil)
 ;; Keep markup visible for editing (use markdown-toggle-markup-hiding to toggle)
 (setq markdown-hide-markup nil)
 ;; Configure list indentation
 (setq markdown-list-indent-width core-tab-width))

;; Key bindings for common markdown operations
(with-eval-after-load
 'markdown-mode
 (define-key markdown-mode-map (kbd "C-c C-l") 'markdown-insert-link)
 (define-key markdown-mode-map (kbd "C-c C-i") 'markdown-insert-image)
 (define-key markdown-mode-map (kbd "C-c C-c b") 'markdown-insert-bold)
 (define-key markdown-mode-map (kbd "C-c C-c i") 'markdown-insert-italic)
 (define-key markdown-mode-map (kbd "C-c C-c c") 'markdown-insert-code))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Mode Hooks - Apply to both markdown-mode and markdown-ts-mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(lang-register-dual-mode-hooks markdown markdown-setup-common)

(core-message-success "Markdown configuration loaded (markdown-mode and markdown-ts-mode)")
(provide 'markdown-config)
;;; markdown-config.el ends here
