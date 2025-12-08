;;; flymake-diagnostic-window.el --- Flymake Diagnostics Window Display -*- lexical-binding: t -*-
;;; Commentary:
;; Functions for displaying Flymake diagnostics in interactive window (F1 key).
;; Uses tabulated-list-mode for sortable, resizable diagnostic display.

;;; Code:
(require 'flymake)
(require 'flymake-diagnostic-data)
(require 'core-table-utils)
(require 'logging-init)

;; External declarations
(declare-function flymake--diagnostics-buffer-entries "flymake")
(declare-function tabulated-list-init-header "tabulated-list")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar
 flymake-diagnostics--last-column-widths
 nil
 "Last calculated column widths for diagnostics table.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 flymake--format-entry-for-display (entry)
 "Convert flymake ENTRY to display format for tabulated-list.
ENTRY is a flymake diagnostic entry from `flymake--diagnostics-buffer-entries'.
The entry format is (plist . [line col type backend message]) where plist contains :diagnostic.

Returns (plist . column-values-array) where column-values-array contains
formatted strings for each column: Line, Col, Type, Code, Backend, Message.

Uses shared `flymake-convert-buffer-entry-to-row' for data extraction.

Example:
  (flymake--format-entry-for-display entry)
  => (plist . [\"42\" \"10\" \"error\" \"F401\" \"Ruff\" \"unused import\"])"
 (let ((row-data (flymake-convert-buffer-entry-to-row entry)))
   (list (car entry) (apply #'vector row-data))))

(defun
 flymake--create-tabulated-format (widths)
 "Create `tabulated-list-format' specification from column WIDTHS.
WIDTHS is a list of 6 integers for columns: Line, Col, Type, Code, Backend, Message.

Returns a vector suitable for `tabulated-list-format' with appropriate
sorting functions and alignment settings:
- Line and Col: right-aligned, Line is sortable
- Type: sortable by severity
- Code, Backend, Message: left-aligned, sortable

Example:
  (flymake--create-tabulated-format \\='(6 5 9 6 12 0))
  => [(...Line spec...) (...Col spec...) ...]"
 (vector
  (list
   "Line"
   (nth 0 widths)
   '(lambda (l1 l2) (< (plist-get (car l1) :line) (plist-get (car l2) :line)))
   :right-align t)
  (list "Col" (nth 1 widths) nil :right-align t)
  (list
   "Type"
   (nth 2 widths)
   '(lambda (l1 l2) (< (plist-get (car l1) :severity) (plist-get (car l2) :severity))))
  (list "Code" (nth 3 widths) t) (list "Backend" (nth 4 widths) t) '("Message" 0 t)))

(defun
 flymake-setup-diagnostic-window ()
 "Set up diagnostic window format with Code column.
Creates a custom `tabulated-list-format' that adds a 'Code' column for error codes
and replaces cryptic backend names with user-friendly versions.

Column layout (all widths calculated dynamically from actual data):
- Line: Line number (right-aligned, sortable)
- Col: Column number (right-aligned)
- Type: Diagnostic type (sortable by severity)
- Code: Error code like F401, I001 (extracted from message)
- Backend: User-friendly backend name
- Message: Full diagnostic text (unlimited width, sortable)"
 ;; Reset cached widths
 (setq flymake-diagnostics--last-column-widths nil)
 ;; Set initial format with minimum widths
 (setq tabulated-list-format (flymake--create-tabulated-format '(4 3 7 4 10 0)))
 ;; Set up dynamic entries function
 (setq
  tabulated-list-entries
  (lambda
   ()
   (let* ((original-entries (flymake--diagnostics-buffer-entries))
          (headers '("Line" "Col" "Type" "Code" "Backend" "Message"))
          ;; Convert entries to rows for width calculation
          (rows
           (mapcar (lambda (entry) (flymake-convert-buffer-entry-to-row entry)) original-entries))
          ;; Calculate base widths
          (base-widths
           (if
            rows
            (core-table-calculate-column-widths headers rows '(4 3 7 4 10 0))
            '(4 3 7 4 10 0)))
          ;; Add column padding
          (new-widths (core-table-add-column-padding base-widths 2)))
     ;; Update format if widths changed
     (unless
      (equal new-widths flymake-diagnostics--last-column-widths)
      (setq flymake-diagnostics--last-column-widths new-widths)
      (setq tabulated-list-format (flymake--create-tabulated-format new-widths))
      (tabulated-list-init-header))
     ;; Return formatted entries
     (mapcar (lambda (entry) (flymake--format-entry-for-display entry)) original-entries))))
 (tabulated-list-init-header))

(provide 'flymake-diagnostic-window)
;;; flymake-diagnostic-window.el ends here
