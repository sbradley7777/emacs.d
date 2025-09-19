;;; imenu-list-config.el --- Imenu List Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Configuration for imenu-list package providing sidebar symbol navigation

(require 'features-constants)
(require 'core-utils)

(core-utils-with-load-timing
 "imenu-list-config.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Imenu-List Configuration
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (use-package
  imenu-list
  :config
  ;; Display settings for terminal compatibility
  (setq imenu-list-size features-imenu-list-size) ; Sidebar width as fraction of frame width
  (setq imenu-list-position 'right) ; Display sidebar on the right
  (setq imenu-list-auto-resize t) ; Automatically resize based on content

  ;; Update behavior
  (setq imenu-list-focus-after-activation t) ; Focus sidebar when opened
  (setq imenu-list-after-jump-hook nil) ; Don't change focus after jumping to symbol

  ;; Terminal-friendly display options
  (setq imenu-list-mode-line-format '("%e" mode-line-front-space "Symbols")) ; Simple modeline

  ;; Key bindings for the imenu-list buffer (no with-eval-after-load needed in :config)
  (define-key imenu-list-major-mode-map (kbd "RET") 'imenu-list-goto-entry)
  (define-key imenu-list-major-mode-map (kbd "TAB") 'hs-toggle-hiding)
  (define-key imenu-list-major-mode-map (kbd "n") 'imenu-list-next-line)
  (define-key imenu-list-major-mode-map (kbd "p") 'imenu-list-prev-line)
  (define-key imenu-list-major-mode-map (kbd "q") 'imenu-list-quit-window)
  (define-key imenu-list-major-mode-map (kbd "r") 'imenu-list-refresh)
  (define-key imenu-list-major-mode-map (kbd "f") 'imenu-list-find-symbol)
  (define-key imenu-list-major-mode-map (kbd "s") 'imenu-list-show-current-symbol)

  (message "✅  Imenu-list configured for terminal-based symbol navigation"))

 ;; Global key bindings for quick access
 ;; The 'imenu-list-focus-after-activation' setting handles focus correctly.
 (global-set-key (kbd "<f1>") 'imenu-list-smart-toggle)
 (global-set-key (kbd "C-c i l") 'imenu-list-smart-toggle)
 (global-set-key (kbd "C-c i s") 'imenu-list-show-current-symbol)
 (global-set-key (kbd "C-c i r") 'imenu-list-refresh)

 ;; Make this module available for loading with (require 'imenu-list-config)
 (provide 'imenu-list-config))
