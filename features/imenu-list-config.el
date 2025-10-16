;;; imenu-list-config.el --- Imenu List Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Configuration for imenu-list package providing sidebar symbol navigation

(require 'features-constants)

(core-utils-with-load-timing
 "imenu-list-config.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Imenu-List Configuration
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (use-package
  imenu-list
  :config
  ;; Display settings for terminal compatibility
  (setq imenu-list-position 'right) ; Display sidebar on the right
  (setq imenu-list-auto-resize t) ; Automatically resize based on content

  ;; Update behavior - disable automatic updates to prevent conflicts with other sidebars
  (setq imenu-list-auto-update nil) ; Disable idle timer updates
  (setq imenu-list-focus-after-activation t) ; Focus sidebar when opened
  (setq imenu-list-after-jump-hook nil) ; Don't change focus after jumping to symbol

  ;; Manually update when switching buffers, but skip special buffers
  (defvar
   imenu-list-excluded-modes
   '(treemacs-mode dashboard-mode)
   "Major modes that should not trigger imenu-list updates.")

  (defun
   imenu-list-smart-update
   ()
   "Update imenu-list only for regular file buffers, not special buffers like treemacs."
   (let ((ilist-open (get-buffer "*Ilist*"))
         (excluded-mode (memq major-mode imenu-list-excluded-modes))
         (hidden-buf (string-prefix-p " " (buffer-name)))
         (special-buf (string-prefix-p "*" (buffer-name))))
     ;; Update if conditions are met
     (when
      (and ilist-open (not excluded-mode) (not hidden-buf) (not special-buf))
      (imenu-list-update t)))) ;; Force update with t parameter

  ;; Update on buffer/window changes
  (add-hook 'buffer-list-update-hook #'imenu-list-smart-update)

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

  (core-message-success "Imenu-list configured for terminal-based symbol navigation"))

 ;; Global key bindings for quick access
 ;; The 'imenu-list-focus-after-activation' setting handles focus correctly.
 ;; F5 uses the wrapper function to ensure mutual exclusion with other side windows
 (global-set-key (kbd "<f5>") 'user-imenu-list-smart-toggle)
 (global-set-key (kbd "C-c i l") 'user-imenu-list-smart-toggle)
 (global-set-key (kbd "C-c i s") 'imenu-list-show-current-symbol)
 (global-set-key (kbd "C-c i r") 'imenu-list-refresh)

 ;; Make this module available for loading with (require 'imenu-list-config)
 (provide 'imenu-list-config))
