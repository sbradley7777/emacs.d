;;; dimmer-config.el --- Dimmer Visual Focus Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Dims inactive buffers to highlight the active window.
;;      Provides enhanced visual focus for terminal and GUI Emacs.
(require 'core-utils)
(require 'core-logging)
(core-utils-with-load-timing
 "dimmer-config.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Dimmer Configuration
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (use-package
  dimmer
  :ensure t
  :config
  ;; Enable dimmer mode globally
  (dimmer-mode t)

  ;; Configure dimming intensity (0.0 = no dimming, 1.0 = completely dark)
  ;; For dark themes like doom-1337, using aggressive dimming for maximum visibility
  (setq dimmer-fraction 0.80)

  ;; IMPORTANT: Only dim foreground for dark themes to avoid whitish-gray background
  ;; Options: :foreground, :background, or :both
  (setq dimmer-adjustment-mode :foreground)

  ;; Use HSL color space for better dark theme compatibility
  ;; Options: :hsl or :rgb (HSL works better with dark themes)
  (setq dimmer-use-colourspace :hsl)

  ;; Prevent dimming certain buffer types
  (setq dimmer-prevent-dimming-predicates '(window-minibuffer-p))

  ;; Configure which-key integration if available
  (when (fboundp 'dimmer-configure-which-key) (dimmer-configure-which-key))

  ;; Exclude certain buffers from being dimmed
  ;; Flymake diagnostics buffer should remain bright so errors are easily visible
  (setq
   dimmer-exclusion-regexp-list
   '("^ \\*Minibuf-[0-9]+\\*$" "^ \\*Echo.*\\*$" "^\\*Flymake diagnostics.*\\*$"))

  (core-message-success "Dimmer configured for dark theme - inactive windows will be dimmed")
  (core-message-info "Dimming: foreground only, HSL color space, 80%% intensity"))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Toggle Function
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  toggle-dimmer ()
  "Toggle dimmer-mode on and off.
When enabled, inactive windows are dimmed for better visual focus.
When disabled, all windows have normal brightness."
  (interactive)
  (if
   dimmer-mode
   (progn
    (dimmer-mode -1) (core-message-info "Dimmer disabled - all windows at normal brightness"))
   (progn
    (dimmer-mode 1) (core-message-success "Dimmer enabled - inactive windows will be dimmed")))))
(provide 'dimmer-config)
;;; dimmer-config.el ends here
