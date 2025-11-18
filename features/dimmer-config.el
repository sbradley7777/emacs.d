;;; dimmer-config.el --- Dimmer Visual Focus Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Dims inactive buffers to highlight the active window.
;;      Provides enhanced visual focus for terminal and GUI Emacs.

;;; Code:
(require 'core-logging)

;; Declare external variables to suppress byte-compiler warnings
(defvar dimmer-fraction) ; From dimmer.el
(defvar dimmer-adjustment-mode) ; From dimmer.el
(defvar dimmer-use-colourspace) ; From dimmer.el
(defvar dimmer-prevent-dimming-predicates) ; From dimmer.el
(defvar dimmer-buffer-exclusion-predicates) ; From dimmer.el
(defvar dimmer-exclusion-predicates) ; From dimmer.el
(defvar dimmer-exclusion-regexp-list) ; From dimmer.el

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

 ;; Prevent dimming the minibuffer itself using built-in window-minibuffer-p predicate
 (setq dimmer-prevent-dimming-predicates '(window-minibuffer-p))

 ;; Exclude buffers displayed in dedicated windows (e.g., transient menus)
 (setq
  dimmer-buffer-exclusion-predicates
  '((lambda
     (buf)
     (let ((windows (get-buffer-window-list buf nil t)))
       (cl-some #'window-dedicated-p windows)))))

 ;; Configure which-key integration if available
 (when (fboundp 'dimmer-configure-which-key) (dimmer-configure-which-key))

 ;; Advice dimmer to prevent excessive updates during minibuffer operations
 ;; This solves the vertico/consult issue where window-configuration-change-hook
 ;; causes dimmer to re-dim buffers during searches (e.g., consult-line)
 ;; We only block dimmer-command-handler and dimmer-config-change-handler
 ;; but allow dimmer-process-all to run so the minibuffer stays bright
 (defun
  dimmer--disable-when-minibuffer-active
  (orig-fun &rest args)
  "Advice for dimmer functions to prevent excessive updates when minibuffer is active."
  (unless (active-minibuffer-window) (apply orig-fun args)))
 (advice-add 'dimmer-command-handler :around #'dimmer--disable-when-minibuffer-active)
 (advice-add 'dimmer-config-change-handler :around #'dimmer--disable-when-minibuffer-active)

 ;; Exclude certain buffers from being dimmed
 ;; Flymake diagnostics buffer should remain bright so errors are easily visible
 (setq
  dimmer-buffer-exclusion-regexps
  '("^ \\*Minibuf-[0-9]+\\*$" "^ \\*Echo.*\\*$" "^\\*Flymake diagnostics.*\\*$"))

 (core-message-success "Dimmer configured for dark theme - inactive windows will be dimmed")
 (core-message-info "Dimming: foreground only, HSL color space, 80%% intensity"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 toggle-dimmer ()
 "Toggle dimmer-mode on and off.
When enabled, inactive windows are dimmed for better visual focus.
When disabled, all windows have normal brightness."
 (interactive)
 (if
  dimmer-mode
  (progn (dimmer-mode -1) (core-message-info "Dimmer disabled - all windows at normal brightness"))
  (progn
   (dimmer-mode 1) (core-message-success "Dimmer enabled - inactive windows will be dimmed"))))
(provide 'dimmer-config)
;;; dimmer-config.el ends here
