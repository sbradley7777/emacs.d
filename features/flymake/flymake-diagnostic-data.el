;;; flymake-diagnostic-data.el --- Flymake Diagnostic Data Extraction -*- lexical-binding: t -*-
;;; Commentary:
;; Shared diagnostic data extraction functions for Flymake.
;; Used by both diagnostics window and export functionality.
;;
;; This file contains functions that extract and format diagnostic data
;; in a tool-agnostic way.  The data can then be formatted differently
;; for interactive display (diagnostics window) or static export (text files).
;;
;; FUTURE: Message-based error code extraction (saved for potential future use)
;; These regex patterns could extract error codes from diagnostic messages:
;;   Pattern 1: "(\\([a-z][a-z-]+\\))" - (line-length), (trailing-spaces)
;;   Pattern 2: "\\[\\([a-z][a-z-]+\\)\\]" - [line-length], [indentation]

;;; Code:
(require 'flymake)
(require 'flymake-registry)
(require 'registry-query)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 flymake-diagnostic-friendly-backend-name (backend-name)
 "Convert backend identifier to friendly description.
BACKEND-NAME can be:
- Abbreviation string from F1 window (e.g., \\='e-f-b\\=')
- Backend symbol from diagnostic object (e.g., \\='eglot-flymake-backend)

Returns friendly description from registry or falls back to formatted name."
 (cond
  ;; If it's already a symbol, use registry-get-description directly
  ((symbolp backend-name)
   (registry-get-description flymake-backend-registry backend-name))
  ;; If it's a string, check if it's an abbreviation or symbol name
  ((stringp backend-name)
   (let ((found-symbol
          (registry-find-by-property flymake-backend-registry :abbreviation backend-name)))
     ;; Get description for found symbol, or try backend-name as symbol name
     (registry-get-description flymake-backend-registry (or found-symbol (intern backend-name)))))
  ;; Fallback for other types
  (t
   (format "%s" backend-name))))

(defun
 flymake-diagnostic-extract-error-code (diag)
 "Extract error code from DIAG's data field or message.
DIAG is a flymake diagnostic object.
Uses built-in `flymake-diagnostic-data' function and structured data access.
For Markdown and Shell files, falls back to parsing error code from message.
Returns error code string if available, or \"-\" otherwise."
 (let* ((data (flymake-diagnostic-data diag))
        (lsp-diag (alist-get 'eglot-lsp-diag data))
        (code (and lsp-diag (plist-get lsp-diag :code)))
        (message (flymake-diagnostic-text diag)))
   (cond
    ;; Filter out "0" as it's not a real error code
    ((and (numberp code) (not (= code 0)))
     (number-to-string code))
    ((and (stringp code) (not (string= code "0")) (not (string= code "")))
     code)
    ;; Fallback: Parse Markdown error codes from start of message (MD001, MD013, etc.)
    ((and message (string-match "^\\(MD[0-9]+\\)" message))
     (match-string 1 message))
    ;; Fallback: Parse ShellCheck error codes from message (SC2086, SC1090, etc.)
    ((and message (string-match "\\(SC[0-9]+\\)" message))
     (match-string 1 message))
    (t
     "-"))))

(defun
 flymake-convert-buffer-entry-to-row (entry)
 "Convert flymake buffer ENTRY to row data for table display.
ENTRY is a flymake diagnostic entry from `flymake--diagnostics-buffer-entries'.
The entry format is (plist . [line col type backend message]) where plist contains :diagnostic.

Returns list: (line col type error-code backend message) suitable for width calculation.

Uses built-in Flymake diagnostic accessors for all data extraction.

Example:
  (flymake-convert-buffer-entry-to-row entry)
  => (\"42\" \"10\" \"error\" \"F401\" \"Ruff\" \"unused import\")"
 (let* ((diag (plist-get (car entry) :diagnostic))
        (values (cadr entry))
        (line (aref values 0))
        (col (aref values 1))
        (type (aref values 2))
        (raw-message (flymake-diagnostic-text diag))
        (message (flymake-diagnostic-sanitize-message raw-message))
        (error-code (flymake-diagnostic-extract-error-code diag))
        (backend (flymake-diagnostic-friendly-backend-name (aref values 3))))
   (list line col type error-code backend message)))

(defun
 flymake-convert-diagnostic-to-row (diag)
 "Convert flymake diagnostic object DIAG to row data for export.
DIAG is a flymake diagnostic object from `flymake-diagnostics'.

Returns list: (line col type error-code backend message) suitable for export.

Uses built-in Flymake diagnostic accessors for all data extraction.
Calculates line and column numbers from buffer positions.

Example:
  (flymake-convert-diagnostic-to-row diag)
  => (\"42\" \"10\" \"eglot-error\" \"F401\" \"Eglot LSP\" \"unused import\")"
 (let* ((buffer (flymake-diagnostic-buffer diag))
        (beg (flymake-diagnostic-beg diag))
        (type (flymake-diagnostic-type diag))
        (backend (flymake-diagnostic-backend diag))
        (raw-message (flymake-diagnostic-text diag))
        (line (with-current-buffer buffer (number-to-string (line-number-at-pos beg))))
        (col
         (with-current-buffer
          buffer (save-excursion (goto-char beg) (number-to-string (current-column)))))
        (type-str (format "%s" type))
        (message (flymake-diagnostic-sanitize-message raw-message))
        (error-code (flymake-diagnostic-extract-error-code diag))
        (backend-name (flymake-diagnostic-friendly-backend-name backend)))
   (list line col type-str error-code backend-name message)))

(defun
 flymake-diagnostic-sanitize-message (message)
 "Sanitize MESSAGE by replacing newlines and multiple spaces.
MESSAGE is a diagnostic message string that may contain newlines.
Returns sanitized string with newlines replaced by single spaces and
consecutive spaces collapsed.

This is essential for proper table formatting in text exports."
 (let ((cleaned (replace-regexp-in-string "\n" " " message)))
   (replace-regexp-in-string "  +" " " cleaned)))

(provide 'flymake-diagnostic-data)
;;; flymake-diagnostic-data.el ends here
