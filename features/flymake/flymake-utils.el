;;; flymake-utils.el --- Flymake Utility Functions -*- lexical-binding: t -*-
;;; Commentary:
;;      Utility functions for Flymake diagnostics formatting and display
(require 'core-constants)
(require 'core-utils)
(core-utils-with-load-timing
 "flymake-utils.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Diagnostics Window Management
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  toggle-flymake-diagnostics-window () "Show or hide the Flymake diagnostics window." (interactive)
  ;; Find any window that is displaying a Flymake diagnostics buffer
  (let ((flymake-window (core-utils-find-window-by-buffer-name "*Flymake diagnostics")))
    ;; If such a window exists, close it. Otherwise, close other exclusive windows and open this one.
    (if
     flymake-window (quit-window nil flymake-window)
     (progn
      (when (fboundp 'user-close-exclusive-side-windows) (user-close-exclusive-side-windows))
      ;; Ensure flymake is loaded before calling flymake-show-buffer-diagnostics
      (require 'flymake nil t)
      (if
       (fboundp 'flymake-show-buffer-diagnostics)
       (flymake-show-buffer-diagnostics)
       (message "Flymake is not available"))))))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Backend Name Formatting
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  flymake-friendly-backend-name (backend-name)
  "Convert cryptic backend names to user-friendly versions.
  Maps internal flymake backend identifiers to readable names:
  - 'f-r---c' (flymake-ruff) -> 'Ruff'
  - 'p-f' (python-flymake) -> 'Python'
  - 'e-f-b' (eglot-flymake-backend) -> 'Eglot'
  - Others -> original name as fallback

  Handles both string and list formats (e.g., (flymake flymake) or \"flymake\")."
  ;; Convert to string if backend-name is a list
  (let ((backend-str
         (cond
          ((stringp backend-name)
           backend-name)
          ((listp backend-name)
           (format "%s" (car backend-name)))
          ((symbolp backend-name)
           (symbol-name backend-name))
          (t
           (format "%s" backend-name)))))
    (cond
     ;; Match flymake-ruff backend identifier
     ((string-match "f-r" backend-str)
      "Ruff")
     ;; Match python-flymake backend identifier
     ((string-match "p-f" backend-str)
      "Python")
     ;; Match eglot-flymake-backend identifier
     ((string-match "e-f-b" backend-str)
      "Eglot")
     ;; Match generic flymake backend
     ((string-match "flymake" backend-str)
      "Flymake")
     ;; Fallback to original name for unknown backends
     (t
      backend-str))))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Diagnostics Buffer Formatting
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  flymake-setup-custom-format (error-code-extractor)
  "Set up custom diagnostics buffer format with Code column.
  Creates a custom tabulated-list-format that adds a 'Code' column for error codes
  and replaces cryptic backend names with user-friendly versions.
  ERROR-CODE-EXTRACTOR is a function that takes a message and returns an error code string.

  Column layout:
  - Line: Line number (5 chars, right-aligned, sortable)
  - Col: Column number (3 chars, right-aligned)
  - Type: Diagnostic type (8 chars, sortable by severity)
  - Code: Error code like F401, I001 (6 chars, extracted from message)
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
               ;; Extract error code from message using provided function
               (error-code (if error-code-extractor (funcall error-code-extractor message) ""))
               ;; Convert backend name to friendly version
               (backend-name (flymake-friendly-backend-name (aref values 3))))
          ;; Return formatted entry with our custom column data
          (list
           diag-data
           (vector
            (aref values 0) ; Line number
            (aref values 1) ; Column number
            (aref values 2) ; Diagnostic type (error/warning)
            error-code ; Extracted error code
            backend-name ; User-friendly backend name
            message)))) ; Full diagnostic message
       original-entries))))
  (tabulated-list-init-header))

 ;; Make this module available for loading with (require 'flymake-utils)
 )
(provide 'flymake-utils)
