;;; flymake-config.el --- Flymake Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Global Flymake configuration for diagnostic display and behavior.
;;
;; Defer-Check Integration (GitHub Issue #55):
;;   Sets `flymake-start-on-flymake-mode' to nil for modes with available LSP.
;;   This prevents auto-start when flymake-mode is enabled, allowing standalone
;;   linters to be added without triggering checks. When eglot connects, it will
;;   trigger the check with both backends ready, preventing "Canceling obsolete
;;   check" warnings. See eglot-config.el for the companion hook that handles
;;   LSP-only modes (like C) that have no standalone linter.

;;; Code:
(require 'core-utils)
(require 'logging-init)
(require 'features-constants)
(require 'flymake-utils)
(require 'flymake-registry)
(require 'flymake-diagnostic-data)
(require 'flymake-diagnostic-window)
(require 'flymake-diagnostic-export)
(require 'eglot-registry)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar flymake--check-timer nil "Timer for debounced backend availability check.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 flymake--config-check-all-buffers ()
 "Check backend availability for all buffers with Flymake enabled.
Runs the check for each buffer in its own context."
 (setq flymake--check-timer nil)
 (dolist
  (buf (buffer-list))
  (when
   (buffer-live-p buf)
   (with-current-buffer
    buf (when (and (boundp 'flymake-mode) flymake-mode) (flymake-check-backend-availability))))))

(defun
 flymake-schedule-backend-check
 ()
 "Schedule a debounced backend availability check.
Cancels existing timer and schedules new check after 3 seconds.
This ensures all flymake backends are properly registered after mode setup.
Multiple calls in quick succession will only trigger one check."
 (when flymake--check-timer (cancel-timer flymake--check-timer))
 (setq flymake--check-timer (run-with-timer 3.0 nil #'flymake--config-check-all-buffers)))

(defun
 flymake--config-enable-for-prog-mode ()
 "Enable Flymake mode for programming buffers, excluding *scratch*.
Sets `flymake-start-on-flymake-mode' to nil if LSP is available, then enables flymake-mode.
This prevents the initial auto-check when flymake-mode is enabled for dual-backend scenarios.
Triggers a debounced backend availability check via `flymake-schedule-backend-check',
unless current mode has defer-check backends with available LSP."
 (unless
  (string= (buffer-name) "*scratch*")
  (let ((has-lsp (registry-has-available-lsp-for-mode-p eglot-lsp-server-registry major-mode)))
    (when has-lsp (setq-local flymake-start-on-flymake-mode nil))
    (flymake-mode 1)
    (unless has-lsp (flymake-schedule-backend-check)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-to-list
 'display-buffer-alist
 '("\\*Flymake diagnostics.*\\*"
   (display-buffer-in-side-window)
   (side . right)
   (window-parameters . ((no-delete-other-windows . t) (no-other-window . nil)))))

(add-hook 'prog-mode-hook 'flymake--config-enable-for-prog-mode)

;; Enforce :disabled flag from registry by removing disabled backends
(add-hook 'flymake-mode-hook 'flymake-remove-disabled-backends)

;; Set up custom diagnostics buffer formatting with friendly backend names and error codes
(add-hook 'flymake-diagnostics-buffer-mode-hook (lambda () (flymake-setup-diagnostic-window)))
(provide 'flymake-config)
;;; flymake-config.el ends here
