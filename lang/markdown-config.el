;;; markdown-config.el --- Markdown Language Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Markdown mode support and configuration for .md files


(core-utils-with-load-timing
 "markdown-config.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Load Markdown mode support
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (require 'markdown-mode)

 ;; File associations for Markdown files
 (add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))
 (add-to-list 'auto-mode-alist '("\\.markdown\\'" . markdown-mode))
 (add-to-list 'auto-mode-alist '("README\\.md\\'" . markdown-mode))

 ;; Markdown-specific configuration
 (add-hook
  'markdown-mode-hook
  (lambda
   () "Configure Markdown mode settings."
   (setq indent-tabs-mode nil) ; Use spaces for indentation
   (setq tab-width core-tab-width) ; Use standard tab width
   (setq markdown-indent-on-enter 'indent-and-new-item) ; Smart indentation on enter
   (setq markdown-enable-math t) ; Enable math syntax highlighting
   (setq markdown-fontify-code-blocks-natively t) ; Syntax highlight code blocks
   (visual-line-mode 1) ; Enable visual line mode for better text wrapping
   (setq fill-column core-fill-column))) ; Use standard fill column

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

 ;; Make this module available for loading with (require 'markdown-config)
 (provide 'markdown-config))
