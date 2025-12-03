;;; flymake-config.el --- Flymake Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Global Flymake configuration for diagnostic display and behavior

;;; Code:
(require 'core-utils)
(require 'core-logging)
(require 'features-constants)
(require 'flymake-utils)

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
Triggers a debounced backend availability check via `flymake-schedule-backend-check'."
 (unless (string= (buffer-name) "*scratch*") (flymake-mode 1) (flymake-schedule-backend-check)))

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

;; Set up custom diagnostics buffer formatting with friendly backend names
;; nil = no custom error-code extractor (uses default, shows "-" in Code column)
(add-hook 'flymake-diagnostics-buffer-mode-hook (lambda () (flymake-setup-custom-format nil)))
(provide 'flymake-config)
;;; flymake-config.el ends here
