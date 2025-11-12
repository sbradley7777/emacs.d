;;; flymake-utils.el --- Flymake Utility Functions -*- lexical-binding: t -*-
;;; Commentary:
;;      Utility functions for Flymake diagnostics formatting and display
(require 'core-constants)
(require 'core-utils)
(require 'core-logging)
(core-utils-with-load-timing
 "flymake-utils.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Diagnostics Window Configuration
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defconst
  flymake-diagnostics-compact-width
  0.3
  "Window width fraction for compact flymake diagnostics view (30% of frame).")
 (defconst
  flymake-diagnostics-expanded-width
  0.5
  "Window width fraction for expanded flymake diagnostics view (50% of frame).")
 (defvar
  flymake-diagnostics--current-width 'compact "Current width state of flymake diagnostics window.")

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Diagnostics Window Management
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  flymake-diagnostics--find-window ()
  "Find the Flymake diagnostics window if it exists.
Returns the window displaying *Flymake diagnostics* buffer, or nil if not found."
  (let ((diag-window nil))
    (walk-windows
     (lambda
      (win)
      (when
       (string-match-p
        "\\*Flymake diagnostics" (buffer-name (window-buffer win)))
       (setq diag-window win)))
     nil t)
    diag-window))
 (defun
  flymake-diagnostics--resize-window
  (window new-width)
  "Resize WINDOW to NEW-WIDTH (fraction of frame width)."
  (let* ((frame-width (frame-width))
         (desired-width (floor (* frame-width new-width)))
         (current-width (window-width window))
         (delta (- desired-width current-width)))
    (when (/= delta 0) (window-resize window delta t))))
 (defun
  toggle-flymake-diagnostics-window ()
  "Toggle the Flymake diagnostics window with size cycling.
When buffer is closed, opens at 30%. When buffer is open, toggles between 30% and 50%.
Automatically focuses the diagnostics window when opened or resized.
Displays syntax errors, warnings, and notes from all active Flymake backends."
  (interactive)
  (let ((existing-window (flymake-diagnostics--find-window)))
    (if
     existing-window
     (progn
      (if
       (eq flymake-diagnostics--current-width 'compact)
       (progn
        (flymake-diagnostics--resize-window
         existing-window flymake-diagnostics-expanded-width)
        (setq flymake-diagnostics--current-width 'expanded))
       (flymake-diagnostics--resize-window existing-window flymake-diagnostics-compact-width)
       (setq flymake-diagnostics--current-width 'compact))
      (select-window existing-window))
     (progn
      (when (fboundp 'user-close-exclusive-side-windows) (user-close-exclusive-side-windows))
      (require 'flymake nil t)
      (if
       (fboundp 'flymake-show-buffer-diagnostics)
       (progn
        (flymake-show-buffer-diagnostics) (setq flymake-diagnostics--current-width 'compact)
        (let ((diag-window (flymake-diagnostics--find-window)))
          (when diag-window (select-window diag-window))))
       (core-message-warning "Flymake is not available"))))))

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
  - 'e-f-c' (elisp-flymake-checkdoc) -> 'Elisp Checkdoc'
  - 'f-a' (flymake-aspell) -> 'Aspell'
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
     ;; Match elisp-flymake-checkdoc identifier
     ((string-match "e-f-c" backend-str)
      "Elisp Checkdoc")
     ;; Match flymake-aspell backend identifier
     ((string-match "f-a" backend-str)
      "Aspell")
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
  - Backend: User-friendly backend name (16 chars, shows 'Ruff' instead of 'f-r---c')
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
    ("Code" 6 t) ("Backend" 16 t) ("Message" 0 t)])
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
