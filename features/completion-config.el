;;; completion-config.el --- Core Auto-Completion Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Modern auto-completion framework using Corfu.
;;      Provides universal auto-completion for all modes and languages.

(require 'features-constants)
(require 'core-utils)

(with-load-timing
 "completion-config.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Corfu Auto-Completion Framework
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


 (use-package
  corfu
  :init
  ;; Enable corfu globally for all buffers
  (global-corfu-mode)

  :config
  ;; Auto-completion settings
  (setq
   corfu-auto t ; Enable automatic completion
   corfu-auto-delay features-corfu-auto-delay ; Short delay before showing completions
   corfu-auto-prefix features-corfu-auto-prefix ; Start completing after N characters
   corfu-cycle t ; Enable cycling through candidates with TAB
   corfu-preview-current 'insert ; Preview current candidate
   corfu-preselect 'prompt ; Preselect based on prompt
   corfu-on-exact-match nil) ; Don't auto-complete on exact match

  ;; Performance optimizations
  (setq
   corfu-min-width features-corfu-min-width ; Minimum popup width
   corfu-max-width features-corfu-max-width ; Maximum popup width
   corfu-count features-corfu-count) ; Maximum number of candidates shown

  ;; Key bindings using define-key (more reliable than :bind)
  (define-key corfu-map (kbd "TAB") #'corfu-next)
  (define-key corfu-map (kbd "<tab>") #'corfu-next)
  (define-key corfu-map (kbd "S-TAB") #'corfu-previous)
  (define-key corfu-map (kbd "<backtab>") #'corfu-previous)
  (define-key corfu-map (kbd "RET") #'corfu-insert)
  (define-key corfu-map (kbd "<return>") #'corfu-insert)

  (message "⚙️  Corfu auto-completion configured successfully")

  ;; Add debugging information
  (message "🛠️  Corfu global mode enabled: %s" (if global-corfu-mode "YES" "NO"))
  (message "🛠️  Corfu auto setting: %s" corfu-auto)
  (message "🛠️  Corfu auto delay: %s" corfu-auto-delay)
  (message "🛠️  Corfu auto prefix: %s" corfu-auto-prefix))

 ;; Global key bindings for manual completion trigger
 ;; Use different key combinations that work reliably
 (global-set-key (kbd "C-c TAB") #'completion-at-point) ; Ctrl+c then TAB
 (global-set-key (kbd "M-TAB") #'completion-at-point) ; Alt+TAB (traditional)
 (global-set-key (kbd "C-M-i") #'completion-at-point) ; Ctrl+Alt+i (traditional alternative)

 ;; Use M-TAB, C-c TAB, or C-M-i for manual completion


 ;; Make this module available for loading with (require 'completion-config)
 (provide 'completion-config))
