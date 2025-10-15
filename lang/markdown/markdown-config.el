;;; markdown-config.el --- Markdown Language Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Markdown mode support and configuration for .md files.
;;      Supports both markdown-mode and markdown-ts-mode with shared configuration.

(require 'core-utils)
(require 'core-logging)
(require 'core-constants)

(core-utils-with-load-timing
 "markdown-config.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Shared Configuration Function
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (defun
  markdown-setup-common
  ()
  "Common setup for both markdown-mode and markdown-ts-mode."
  (setq indent-tabs-mode nil)
  (setq tab-width core-tab-width)
  (setq markdown-indent-on-enter 'indent-and-new-item)
  (setq markdown-enable-math t)
  (setq markdown-fontify-code-blocks-natively t)
  (visual-line-mode 1)
  (setq fill-column core-fill-column))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Markdown Mode Configuration
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (require 'markdown-mode)

 ;; File associations (treesit-auto overrides when grammar available)
 (add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))
 (add-to-list 'auto-mode-alist '("\\.markdown\\'" . markdown-mode))
 (add-to-list 'auto-mode-alist '("README\\.md\\'" . markdown-mode))

 ;; Terminal-friendly settings (no external preview dependencies)
 (with-eval-after-load
  'markdown-mode
  ;; Disable live preview by default (terminal-friendly)
  (setq markdown-live-preview-engine nil)
  ;; Use simple markup hiding for better terminal readability
  (setq markdown-hide-markup nil) ; Keep markup visible for terminal editing
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

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Mode Hooks - Apply to both markdown-mode and markdown-ts-mode
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;; Apply common setup to markdown-mode
 (add-hook 'markdown-mode-hook 'markdown-setup-common)

 ;; Apply common setup to markdown-ts-mode (when tree-sitter grammar available)
 (add-hook 'markdown-ts-mode-hook 'markdown-setup-common)

 (core-message-success "Markdown configuration loaded (markdown-mode and markdown-ts-mode)"))

(provide 'markdown-config)

;;; markdown-config.el ends here
