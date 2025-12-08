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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 flymake-diagnostic-friendly-backend-name (backend-name)
 "Convert backend abbreviations to user-friendly names.
Looks up BACKEND-NAME (abbreviation string) in `flymake-backend-registry' and returns
the friendly description, or the original name if no match found.

BACKEND-NAME can be:
- String abbreviation (e.g., \\='f-s--\\=', \\='e-f-b\\=')
- Backend symbol (e.g., \\='flymake-shellcheck--backend)
- List format (e.g., (flymake flymake))

Returns the friendly name from the registry or the original name as fallback."
 (let ((backend-str
        (cond
         ((stringp backend-name)
          backend-name)
         ((listp backend-name)
          (format "%s" (car backend-name)))
         ((symbolp backend-name)
          (symbol-name backend-name))
         (t
          (format "%s" backend-name))))
       (friendly-name nil))
   ;; Search unified registry for matching abbreviation
   (catch
    'found
    (dolist
     (entry flymake-backend-registry)
     (let ((abbrev (plist-get (nthcdr 3 entry) :abbreviation))
           (description (nth 1 entry)))
       (when
        (and abbrev (string= abbrev backend-str))
        (setq friendly-name description)
        (throw 'found friendly-name)))))
   ;; Return friendly name or fall back to original
   (or friendly-name backend-str)))

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
 flymake-diagnostic-entry-to-row (entry)
 "Convert flymake ENTRY to row data for table display.
ENTRY is a flymake diagnostic entry from `flymake--diagnostics-buffer-entries'.
The entry format is (plist . [line col type backend message]) where plist contains :diagnostic.

Returns list: (line col type error-code backend message) suitable for width calculation.

Uses built-in Flymake diagnostic accessors for all data extraction.

Example:
  (flymake-diagnostic-entry-to-row entry)
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
