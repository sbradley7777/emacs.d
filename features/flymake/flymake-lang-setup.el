;;; flymake-lang-setup.el --- Flymake Language Mode Setup Utilities -*- lexical-binding: t -*-
;;; Commentary:
;; Shared utilities for configuring flymake in language modes.
;; Provides common patterns for standalone backends and dual backend (flymake + LSP) setups.
;;
;; Usage:
;;   (require 'flymake-lang-setup)
;;   (lang-trigger-flymake-check-timer)

;;; Code:
(require 'flymake)
(require 'core-utils)

;; External declarations
(defvar flymake-config--check-timer)
(defvar eglot--managed-mode)
(declare-function flymake-config--check-all-buffers "flymake-config")
(declare-function flymake-start "flymake")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 lang-setup-flymake-backend (binary backend-function)
 "Set up standalone flymake BACKEND-FUNCTION if BINARY is available.
BINARY is the name of the executable to check for (e.g., \"mdl\", \"yamllint\").
BACKEND-FUNCTION is the flymake backend function symbol (e.g., \\='flymake-collection-markdownlint).
Adds BACKEND-FUNCTION to `flymake-diagnostic-functions' buffer-locally."
 (when
  (and (core-utils-check-command-in-path binary) (fboundp backend-function))
  (add-hook 'flymake-diagnostic-functions backend-function nil t)))

(defun
 lang-ensure-flymake-backend-after-eglot (binary backend-function)
 "Ensure BACKEND-FUNCTION is active after eglot starts.
BINARY is the name of the executable to check for (e.g., \"mdl\").
BACKEND-FUNCTION is the flymake backend function symbol (e.g., \\='flymake-collection-markdownlint).
Eglot can sometimes reset the diagnostic functions list, so we re-add the backend if missing."
 (when
  (and
   (bound-and-true-p eglot--managed-mode)
   (core-utils-check-command-in-path binary)
   (fboundp backend-function))
  (unless
   (memq backend-function flymake-diagnostic-functions)
   (add-hook 'flymake-diagnostic-functions backend-function nil t)
   (flymake-start))))

(defun
 lang-add-eglot-backend-hook (binary backend-function)
 "Add hook to ensure BACKEND-FUNCTION persists after eglot starts.
BINARY is the name of the executable (e.g., \"mdl\").
BACKEND-FUNCTION is the flymake backend function symbol (e.g., \\='flymake-collection-markdownlint).
This addresses the issue where eglot can reset `flymake-diagnostic-functions'."
 (add-hook
  'eglot-managed-mode-hook
  (lambda () (lang-ensure-flymake-backend-after-eglot binary backend-function))
  nil
  t))

(defun
 lang-setup-flymake-dual-backend
 (binary backend-function)
 "Set up dual flymake backend: standalone + eglot persistence.
BINARY is the executable name (e.g., \"mdl\", \"yamllint\").
BACKEND-FUNCTION is the flymake backend symbol (e.g., \\='flymake-collection-markdownlint).

This handles the common pattern where a language has both:
1. A standalone flymake backend (linter)
2. An LSP server via eglot

The function sets up the backend, enables flymake, ensures persistence after eglot,
and triggers the configuration check timer."
 (lang-setup-flymake-backend binary backend-function)
 (flymake-mode 1)
 (lang-add-eglot-backend-hook binary backend-function)
 (lang-trigger-flymake-check-timer))

(defun
 lang-setup-flymake-standalone-backend
 (binary backend-function)
 "Set up standalone flymake backend (no eglot).
BINARY is the executable name (e.g., \"jsonlint\").
BACKEND-FUNCTION is the flymake backend symbol (e.g., \\='flymake-collection-jsonlint).

For languages that only have a standalone linter, no LSP server."
 (lang-setup-flymake-backend binary backend-function)
 (flymake-mode 1)
 (lang-trigger-flymake-check-timer))

(defun
 lang-trigger-flymake-check-timer ()
 "Trigger flymake configuration check timer.
Cancels existing timer and schedules new check after 3 seconds.
This ensures all flymake backends are properly registered after mode setup."
 (when
  (boundp 'flymake-config--check-timer)
  (when flymake-config--check-timer (cancel-timer flymake-config--check-timer))
  (setq flymake-config--check-timer (run-with-timer 3.0 nil #'flymake-config--check-all-buffers))))

(provide 'flymake-lang-setup)
;;; flymake-lang-setup.el ends here
