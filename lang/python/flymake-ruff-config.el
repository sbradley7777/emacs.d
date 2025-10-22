;;; flymake-ruff-config.el --- Flymake Ruff Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Configuration for flymake-ruff with custom diagnostics buffer formatting
;;      that adds error code extraction in a separate column.
(require 'core-utils)
(require 'flymake-utils)
(core-utils-with-load-timing
 "flymake-ruff-config.el"
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Flymake Ruff Configuration
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; NOTE: Ruff runs locally (not remotely) because flymake operates on buffer content in the local Emacs process.
 ;; Unlike LSP servers (e.g., pylsp) which need remote execution to access project structure and dependencies,
 ;; ruff analyzes code directly via stdin and doesn't require filesystem access to the remote host.
 ;; Only configure ruff if it's available in local PATH
 (when
  (core-utils-check-command-in-path "ruff")

  (defun
   flymake-ruff-setup () "Common Flymake Ruff setup for both python-mode and python-ts-mode."
   ;; Remove the default python checker (with backend name: p-f) to avoid duplicates
   (remove-hook 'flymake-diagnostic-functions 'python-flymake t)
   ;; Add the ruff checker
   (flymake-ruff-load)
   ;; Enable flymake-mode to activate diagnostics
   (flymake-mode 1))

  ;; Configure flymake-ruff for both python-mode and python-ts-mode
  (add-hook 'python-mode-hook #'flymake-ruff-setup)
  (add-hook 'python-ts-mode-hook #'flymake-ruff-setup))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Ruff Error Code Extraction
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  flymake-ruff-extract-error-code (message)
  "Extract error code from ruff diagnostic message.
  Ruff messages typically contain error codes like F401, I001, E402, etc.
  This function extracts those codes using regex pattern ([A-Z][0-9]+)."
  (let ((msg-text
         (cond
          ;; Handle simple string messages
          ((stringp message)
           message)
          ;; Handle propertized strings (list with string as first element)
          ((and (listp message) (stringp (car message)))
           (car message))
          ;; Fallback: convert anything else to string
          (t
           (format "%s" message)))))
    ;; Match pattern like F401, I001, E402 (letter followed by digits)
    (if (string-match "\\([A-Z][0-9]+\\)" msg-text) (match-string 1 msg-text) "")))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Custom Diagnostics Buffer Formatting
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Set up custom diagnostics formatting using the generic flymake utilities
 (add-hook
  'flymake-diagnostics-buffer-mode-hook
  (lambda () (flymake-setup-custom-format 'flymake-ruff-extract-error-code))))
(provide 'flymake-ruff-config)
