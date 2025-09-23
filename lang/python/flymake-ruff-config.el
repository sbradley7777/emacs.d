;;; flymake-ruff-config.el --- Flymake Ruff Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Configuration for flymake-ruff with custom diagnostics buffer formatting
;;      that adds error code extraction in a separate column.

(require 'core-constants)
(require 'core-utils)

(core-utils-with-load-timing
 "flymake-ruff-config.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Flymake Ruff Configuration
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;; Only configure ruff if it's available in PATH
 (when
  (core-utils-check-command-in-path "ruff")

  ;; Configure flymake-ruff to replace built-in python checker
  (add-hook
   'python-mode-hook
   (lambda
    ()
    ;; Remove the default python checker (with backend name: p-f) to avoid duplicates
    (remove-hook 'flymake-diagnostic-functions 'python-flymake t)
    ;; Add the ruff checker
    (flymake-ruff-load)))
  ;; Enable flymake-mode to activate diagnostics. The only enabled backend is flymake-ruff:"f-r---c"
  (add-hook 'python-mode-hook 'flymake-mode))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Custom Diagnostics Buffer Formatting
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;; Only set up custom formatting if ruff is available
 (when
  (executable-find "ruff")

  (defun
   flymake-extract-error-code (message)
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

  (defun
   flymake-friendly-backend-name (backend-name)
   "Convert cryptic backend names to user-friendly versions.
  Maps internal flymake backend identifiers to readable names:
  - 'f-r---c' (flymake-ruff) -> 'Ruff'
  - 'p-f' (python-flymake) -> 'Python'
  - Others -> original name as fallback"
   (cond
    ;; Match flymake-ruff backend identifier
    ((string-match "f-r" backend-name)
     "Ruff")
    ;; Match python-flymake backend identifier
    ((string-match "p-f" backend-name)
     "Python")
    ;; Fallback to original name for unknown backends
    (t
     backend-name)))

  (defun
   flymake-setup-custom-format ()
   "Set up custom diagnostics buffer format with Code column.
  Creates a custom tabulated-list-format that adds a 'Code' column for ruff error codes
  and replaces cryptic backend names with user-friendly versions.

  Column layout:
  - Line: Line number (5 chars, right-aligned, sortable)
  - Col: Column number (3 chars, right-aligned)
  - Type: Diagnostic type (8 chars, sortable by severity)
  - Code: Ruff error code like F401, I001 (6 chars, extracted from message)
  - Backend: User-friendly backend name (8 chars, shows 'Ruff' instead of 'f-r---c')
  - Message: Full diagnostic text (unlimited width, sortable)"
   (setq
    tabulated-list-format
    [("Line"
      5
      (lambda (l1 l2) (< (plist-get (car l1) :line) (plist-get (car l2) :line)))
      :right-align t)
     ("Col" 3 nil :right-align t)
     ("Type"
      8
      (lambda (l1 l2) (< (plist-get (car l1) :severity) (plist-get (car l2) :severity))))
     ("Code" 6 t) ("Backend" 8 t) ("Message" 0 t)])
   ;; Override the entries function to customize data extraction
   ;; This function processes each diagnostic entry and extracts/formats the data
   ;; for our custom column layout
   (setq
    tabulated-list-entries
    (lambda
     ()
     ;; Get the original diagnostic entries from flymake
     (let ((original-entries (flymake--diagnostics-buffer-entries)))
       ;; Process each entry to extract and format data for our columns
       (mapcar
        (lambda
         (entry)
         (let* ((diag-data (car entry)) ; Diagnostic metadata
                (values (cadr entry)) ; Column values array
                (message (aref values 4)) ; Original message text
                ;; Extract ruff error code from message (F401, I001, etc.)
                (error-code (flymake-extract-error-code message))
                ;; Convert backend name from 'f-r---c' to 'Ruff'
                (backend-name (flymake-friendly-backend-name (aref values 3))))
           ;; Return formatted entry with our custom column data
           (list
            diag-data
            (vector
             (aref values 0) ; Line number
             (aref values 1) ; Column number
             (aref values 2) ; Diagnostic type (error/warning)
             error-code ; Extracted ruff code (F401, I001, etc.)
             backend-name ; User-friendly backend name (Ruff)
             message)))) ; Full diagnostic message
        original-entries))))
   (tabulated-list-init-header))

  (add-hook 'flymake-diagnostics-buffer-mode-hook #'flymake-setup-custom-format)))

(provide 'flymake-ruff-config)
