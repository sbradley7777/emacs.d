;;; imenu-list-config.el --- Imenu List Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Configuration for imenu-list package providing sidebar symbol navigation

(require 'features-constants)

(defvar config-load-start-time (current-time))
(message "🔄  Loading imenu-list-config.el...")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Imenu-List Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package
 imenu-list
 :config
 ;; Display settings for terminal compatibility
 (setq imenu-list-size 0.25) ; Sidebar width as fraction of frame width
 (setq imenu-list-position 'right) ; Display sidebar on the right
 (setq imenu-list-auto-resize t) ; Automatically resize based on content

 ;; Update behavior
 (setq imenu-list-focus-after-activation t) ; Focus sidebar when opened
 (setq imenu-list-after-jump-hook nil) ; Don't change focus after jumping to symbol

 ;; Terminal-friendly display options
 (setq imenu-list-mode-line-format '("%e" mode-line-front-space "Symbols")) ; Simple modeline

 ;; Integration with eglot - automatic updates when LSP provides new symbols
 (add-hook
  'imenu-list-update-hook
  (lambda
   ()
   "Update imenu-list when eglot provides new symbol information."
   (when (and (featurep 'eglot) (eglot-managed-p)) (imenu-list-update-safe))))

 ;; Key bindings for the imenu-list buffer
 (with-eval-after-load
  'imenu-list
  (define-key imenu-list-major-mode-map (kbd "RET") 'imenu-list-goto-entry)
  (define-key imenu-list-major-mode-map (kbd "TAB") 'hs-toggle-hiding)
  (define-key imenu-list-major-mode-map (kbd "n") 'imenu-list-next-line)
  (define-key imenu-list-major-mode-map (kbd "p") 'imenu-list-prev-line)
  (define-key imenu-list-major-mode-map (kbd "q") 'imenu-list-quit-window)
  (define-key imenu-list-major-mode-map (kbd "r") 'imenu-list-refresh)
  (define-key imenu-list-major-mode-map (kbd "f") 'imenu-list-find-symbol)
  (define-key imenu-list-major-mode-map (kbd "s") 'imenu-list-show-current-symbol))

 (message "✅  Imenu-list configured for terminal-based symbol navigation"))

;; Global key bindings for quick access
(global-set-key (kbd "C-c i l") 'imenu-list-smart-toggle) ; Toggle imenu-list sidebar
(global-set-key (kbd "C-c i s") 'imenu-list-show-current-symbol) ; Show current symbol in sidebar
(global-set-key (kbd "C-c i r") 'imenu-list-refresh) ; Refresh symbol list

;; Automatic activation for Python files (optional - can be disabled if too intrusive)
;; (add-hook 'python-mode-hook
;;   (lambda ()
;;     "Auto-show imenu-list for Python files."
;;     (when (and (buffer-file-name) (> (buffer-size) 1000)) ; Only for file-backed buffers > 1KB
;;       (imenu-list-minor-mode 1))))

;; Helper function to toggle imenu-list with better terminal handling
(defun
 imenu-list-smart-toggle-with-focus
 ()
 "Toggle imenu-list and handle focus appropriately for terminal usage."
 (interactive)
 (if
  (get-buffer-window imenu-list-buffer-name) (imenu-list-quit-window)
  (progn
   (imenu-list-smart-toggle)
   ;; In terminal mode, briefly focus the sidebar to show it's active
   (when
    (not (display-graphic-p))
    (let ((imenu-window (get-buffer-window imenu-list-buffer-name)))
      (when
       imenu-window (select-window imenu-window)
       (run-with-timer
        0.5 nil
        (lambda
         () (when (window-live-p (get-buffer-window (current-buffer))) (other-window 1))))))))))

;; Replace the default binding with our enhanced version
(global-set-key (kbd "C-c i l") 'imenu-list-smart-toggle-with-focus)

;; Make this module available for loading with (require 'imenu-list-config)
(provide 'imenu-list-config)
(message
 "imenu-list-config.el loaded (%.2fs)"
 (float-time (time-subtract (current-time) config-load-start-time)))
