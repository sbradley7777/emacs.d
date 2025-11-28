;;; core-ui-utils.el --- UI and Window Management Utilities -*- lexical-binding: t -*-
;;; Commentary:
;; Utility functions for window management, buffer finding, and UI operations.

;;; Code:
(require 'subr-x)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 core-ui-utils-calculate-column-widths (headers rows &optional min-widths)
 "Calculate dynamic column widths for HEADERS and ROWS.
HEADERS is a list of column header strings.
ROWS is a list of row data, where each row is a list of column values.
MIN-WIDTHS is an optional list of minimum widths per column.

Returns a list of integers representing the calculated width for each column.
Each width is the maximum of:
  1. Header length
  2. Longest data item in that column
  3. Minimum width (if specified)

Example:
  (core-ui-utils-calculate-column-widths
   \\='(\"Name\" \"Age\" \"City\")
   \\='((\"Alice\" \"25\" \"NYC\")
     (\"Bob\" \"30\" \"SF\"))
   \\='(10 3 5))
  => (10 3 5)  ; Name=10 (min), Age=3, City=5 (min)"
 (let ((num-cols (length headers)))
   (mapcar
    (lambda
     (col-idx)
     (let ((header-width (length (nth col-idx headers)))
           (data-width
            (if
             rows
             (apply 'max (mapcar (lambda (row) (length (format "%s" (nth col-idx row)))) rows)) 0))
           (min-width (if min-widths (nth col-idx min-widths) 0)))
       (max header-width data-width min-width)))
    (number-sequence 0 (1- num-cols)))))

(defun
 core-ui-utils-add-column-padding (widths padding)
 "Add PADDING to each width in WIDTHS list, except the last column.
WIDTHS is a list of column widths.
PADDING is the number of spaces to add to each column (except the last).

Returns new widths list with padding applied.
The last column receives no padding (typically for unlimited-width columns).

Example:
  (core-ui-utils-add-column-padding \\='(4 3 7 10) 2)
  => (6 5 9 10)  ; First 3 columns +2, last column unchanged"
 (let ((result nil)
       (len (length widths)))
   (dotimes
    (i len)
    (push
     (if
      (= i (1- len))
      (nth i widths) ; Last column - no padding
      (+ (nth i widths) padding)) ; Other columns - add padding
     result))
   (nreverse result)))

(defun
 core-ui-utils--column-is-numeric-p (column-index rows)
 "Check if column at COLUMN-INDEX contain only numeric values in ROWS.
Returns t if all values are numeric (integers or floats), nil otherwise.
Empty strings or whitespace-only values are treated as non-numeric."
 (and
  rows
  (cl-every
   (lambda
    (row)
    (let ((value (format "%s" (nth column-index row))))
      (and
       (not (string-empty-p (string-trim value)))
       (string-match-p "\\`[0-9]+\\(?:\\.[0-9]+\\)?\\'" (string-trim value)))))
   rows)))

(defun
 core-ui-utils--detect-column-alignments (headers rows)
 "Detect alignment for each column based on data types.
HEADERS is the list of column header strings.
ROWS is the list of data rows.
Returns a list of alignment symbols: \\='left or \\='right for each column.
Numeric columns (and their headers) get \\='right alignment."
 (let ((num-cols (length headers)))
   (mapcar
    (lambda (col-idx) (if (core-ui-utils--column-is-numeric-p col-idx rows) 'right 'left))
    (number-sequence 0 (1- num-cols)))))

(defun
 core-ui-utils--build-row (columns widths alignments)
 "Build a data row with vertical borders.
COLUMNS is a list of column values.
WIDTHS is a list of column widths.
ALIGNMENTS is a list of alignment symbols (\\='left or \\='right) for each column.
Returns formatted row string like: │ Data  │ Data  │ Data  │"
 (concat
  "│ "
  (mapconcat
   (lambda
    (triplet)
    (let* ((col (format "%s" (nth 0 triplet)))
           (width (nth 1 triplet))
           (align (nth 2 triplet))
           (padding (- width (length col))))
      (if
       (eq align 'right)
       (concat (make-string (max 0 padding) ?\s) col)
       (concat col (make-string (max 0 padding) ?\s)))))
   (cl-mapcar 'list columns widths alignments) " │ ")
  " │"))

(defun
 core-ui-utils--build-border (widths type)
 "Build a horizontal border line with box-drawing characters.
WIDTHS is a list of column widths.
TYPE is \\='top, \\='middle, or \\='bottom.
Returns border string with appropriate box-drawing characters.

Examples:
  (core-ui-utils--build-border \\='(5 3 4) \\='top)
  => \"┌───────┬─────┬──────┐\"
  (core-ui-utils--build-border \\='(5 3 4) \\='middle)
  => \"├───────┼─────┼──────┤\"
  (core-ui-utils--build-border \\='(5 3 4) \\='bottom)
  => \"└───────┴─────┴──────┘\""
 (let ((left
        (pcase type
          ('top "┌")
          ('middle "├")
          ('bottom "└")))
       (junction
        (pcase type
          ('top "┬")
          ('middle "┼")
          ('bottom "┴")))
       (right
        (pcase type
          ('top "┐")
          ('middle "┤")
          ('bottom "┘"))))
   (concat left (mapconcat (lambda (width) (make-string (+ width 2) ?─)) widths junction) right)))

(defun
 core-ui-utils-format-table (headers rows)
 "Format HEADERS and ROWS as a box-drawing table.
HEADERS is a list of column header strings.
ROWS is a list of row data, where each row is a list of column values.

Returns a list of formatted strings with box-drawing characters.
Uses `core-ui-utils-calculate-column-widths' for dynamic column sizing.
Automatically right-aligns numeric columns (both headers and data).

Example:
  (core-ui-utils-format-table
   \\='(\"Name\" \"Age\" \"City\")
   \\='((\"Alice\" \"25\" \"NYC\")
     (\"Bob\" \"30\" \"SF\")
     (\"Charlie\" \"35\" \"LA\")))

Returns:
  (\"┌─────────┬─────┬──────┐\"
   \"│ Name    │ Age │ City │\"
   \"├─────────┼─────┼──────┤\"
   \"│ Alice   │  25 │ NYC  │\"
   \"│ Bob     │  30 │ SF   │\"
   \"│ Charlie │  35 │ LA   │\"
   \"└─────────┴─────┴──────┘\")"
 (let* ((col-widths (core-ui-utils-calculate-column-widths headers rows))
        (alignments (core-ui-utils--detect-column-alignments headers rows))
        (lines nil))
   ;; Top border: ┌───┬───┬───┐
   (push (core-ui-utils--build-border col-widths 'top) lines)
   ;; Header row: │ Col │ Col │ Col │
   (push (core-ui-utils--build-row headers col-widths alignments) lines)
   ;; Header separator: ├───┼───┼───┤
   (push (core-ui-utils--build-border col-widths 'middle) lines)
   ;; Data rows: │ Data │ Data │ Data │
   (dolist (row rows) (push (core-ui-utils--build-row row col-widths alignments) lines))
   ;; Bottom border: └───┴───┴───┘
   (push (core-ui-utils--build-border col-widths 'bottom) lines)
   (nreverse lines)))

(defun
 core-ui-utils-find-window-by-buffer-name (buffer-name-pattern &optional exact-match)
 "Find window displaying buffer matching BUFFER-NAME-PATTERN.
If EXACT-MATCH is non-nil, match buffer name exactly using string=.
Otherwise, use `string-prefix-p' for prefix matching (default).
Returns the window if found, nil otherwise.

Example:
  (core-ui-utils-find-window-by-buffer-name \"*Flymake diagnostics\")
  (core-ui-utils-find-window-by-buffer-name \"*Ilist*\" t)"
 (require 'cl-lib)
 (cl-find-if
  (lambda
   (window)
   (let ((buffer-name (buffer-name (window-buffer window))))
     (if
      exact-match
      (string= buffer-name-pattern buffer-name)
      (string-prefix-p buffer-name-pattern buffer-name))))
  (window-list)))

(defun
 core-ui-utils-close-window-by-buffer-name (buffer-name-pattern &optional exact-match)
 "Close window displaying buffer matching BUFFER-NAME-PATTERN.
If EXACT-MATCH is non-nil, match buffer name exactly using string=.
Otherwise, use `string-prefix-p' for prefix matching (default).
Returns t if window was found and closed, nil otherwise.

Example:
  (core-ui-utils-close-window-by-buffer-name \"*Flymake diagnostics\")
  (core-ui-utils-close-window-by-buffer-name \"*Ilist*\" t)"
 (let ((window (core-ui-utils-find-window-by-buffer-name buffer-name-pattern exact-match)))
   (when window (quit-window nil window) t)))

(defun
 core-ui-utils-resize-window-to-ratio (window width-ratio)
 "Resize WINDOW to WIDTH-RATIO of frame width.
WIDTH-RATIO is a decimal between 0.0 and 1.0 (e.g., 0.3 for 30%).
Calculates the desired width and resizes the window horizontally."
 (let* ((frame-width (frame-width))
        (desired-width (floor (* frame-width width-ratio)))
        (current-width (window-width window))
        (delta (- desired-width current-width)))
   (when (/= delta 0) (window-resize window delta t))))

(provide 'core-ui-utils)
;;; core-ui-utils.el ends here
