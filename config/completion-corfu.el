;;; completion-corfu.el --- Corfu Auto-Completion Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Modern auto-completion framework using Corfu.
;;      Provides universal auto-completion for all modes and languages.

(defvar config-load-start-time (current-time))
(message "Loading completion-corfu.el...")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Corfu Auto-Completion Framework
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Define helper function for TAB behavior
(defun
 corfu-insert-or-complete () "Insert completion or trigger completion-at-point." (interactive)
 (if
  (and
   (bound-and-true-p corfu-mode) (not (and (fboundp 'corfu--popup-p) (corfu--popup-p))))
  (completion-at-point) (indent-for-tab-command)))

(use-package
 corfu
 :init
 ;; Enable corfu globally for all buffers
 (global-corfu-mode)

 :config
 ;; Auto-completion settings
 (setq
  corfu-auto t ; Enable automatic completion
  corfu-auto-delay 0.2 ; Short delay before showing completions (200ms)
  corfu-auto-prefix 1 ; Start completing after 1 character
  corfu-cycle t ; Enable cycling through candidates with TAB
  corfu-preview-current 'insert ; Preview current candidate
  corfu-preselect 'prompt ; Preselect based on prompt
  corfu-on-exact-match nil) ; Don't auto-complete on exact match

 ;; Performance optimizations
 (setq
  corfu-min-width 20 ; Minimum popup width
  corfu-max-width 100 ; Maximum popup width
  corfu-count 10) ; Maximum number of candidates shown

 ;; Key bindings using define-key (more reliable than :bind)
 (define-key corfu-map (kbd "TAB") #'corfu-next)
 (define-key corfu-map (kbd "<tab>") #'corfu-next)
 (define-key corfu-map (kbd "S-TAB") #'corfu-previous)
 (define-key corfu-map (kbd "<backtab>") #'corfu-previous)
 (define-key corfu-map (kbd "RET") #'corfu-insert)
 (define-key corfu-map (kbd "<return>") #'corfu-insert)

 (message "Corfu auto-completion configured successfully")

 ;; Add debugging information
 (message "Corfu global mode enabled: %s" (if (bound-and-true-p global-corfu-mode) "YES" "NO"))
 (message "Corfu auto setting: %s" corfu-auto)
 (message "Corfu auto delay: %s" corfu-auto-delay)
 (message "Corfu auto prefix: %s" corfu-auto-prefix))

;; Global key bindings for manual completion trigger
;; Use different key combinations that work reliably
(global-set-key (kbd "C-c TAB") #'completion-at-point) ; Ctrl+c then TAB
(global-set-key (kbd "M-TAB") #'completion-at-point) ; Alt+TAB (traditional)
(global-set-key (kbd "C-M-i") #'completion-at-point) ; Ctrl+Alt+i (traditional alternative)

;; For regular TAB to trigger completion when not in completion mode
(defun
 smart-tab () "Smart TAB: complete if possible, otherwise indent." (interactive)
 (if
  (minibufferp) (minibuffer-complete)
  (if
   (and (boundp 'corfu-mode) corfu-mode)
   (or (completion-at-point) (indent-for-tab-command))
   (indent-for-tab-command))))

;; Bind TAB globally to smart completion
(global-set-key (kbd "TAB") #'smart-tab)

;; Diagnostic function to check completion setup
(defun
 corfu-debug-info
 ()
 "Display debug information about Corfu and completion setup."
 (interactive)
 (message "\n=== Corfu Debug Information ===")
 (message "Global Corfu Mode: %s" (if (bound-and-true-p global-corfu-mode) "ENABLED" "DISABLED"))
 (message "Local Corfu Mode: %s" (if (bound-and-true-p corfu-mode) "ENABLED" "DISABLED"))
 (message "Corfu Auto: %s" (if (bound-and-true-p corfu-auto) "ENABLED" "DISABLED"))
 (message "Corfu Auto Delay: %s" (if (boundp 'corfu-auto-delay) corfu-auto-delay "NOT SET"))
 (message "Corfu Auto Prefix: %s" (if (boundp 'corfu-auto-prefix) corfu-auto-prefix "NOT SET"))
 (message "Current Major Mode: %s" major-mode)
 (message "Completion At Point Functions: %s" completion-at-point-functions)
 (message "Eglot Mode: %s" (if (bound-and-true-p eglot--managed-mode) "ACTIVE" "INACTIVE"))
 (when (bound-and-true-p eglot--managed-mode) (message "Eglot Server: %s" (eglot-current-server)))
 (message "==============================="))

;; Make this module available for loading with (require 'completion-corfu)
(provide 'completion-corfu)
(message
 "completion-corfu.el loaded (%.2fs)"
 (float-time (time-subtract (current-time) config-load-start-time)))
