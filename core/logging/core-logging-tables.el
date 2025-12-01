;;; core-logging-tables.el --- Table Formatting for Logging and Diagnostics -*- lexical-binding: t -*-

;;; Commentary:
;; Table formatting utilities for diagnostic output and logging.
;; Provides box-drawing table rendering with automatic column sizing,
;; alignment detection, and right-alignment for numeric columns.

;;; Code:
(require 'subr-x)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 core-logging-calculate-column-widths (headers rows &optional min-widths)
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
  (core-logging-calculate-column-widths
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
 core-logging-add-column-padding (widths padding)
 "Add PADDING to each width in WIDTHS list, except the last column.
WIDTHS is a list of column widths.
PADDING is the number of spaces to add to each column (except the last).

Returns new widths list with padding applied.
The last column receives no padding (typically for unlimited-width columns).

Example:
  (core-logging-add-column-padding \\='(4 3 7 10) 2)
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
 core-logging--column-is-numeric-p (column-index rows)
 "Check if column at COLUMN-INDEX contain only numeric values in ROWS.
Returns t if all values are numeric (integers, floats, or fractions).
Empty strings or whitespace-only values are treated as non-numeric.
Numeric patterns recognized:
  - Integers: \"123\"
  - Floats: \"123.45\"
  - Fractions: \"3/5\", \"10/20\""
 (and
  rows
  (cl-every
   (lambda
    (row)
    (let ((value (format "%s" (nth column-index row))))
      (and
       (not (string-empty-p (string-trim value)))
       (string-match-p "\\`[0-9]+\\(?:\\.[0-9]+\\|/[0-9]+\\)?\\'" (string-trim value)))))
   rows)))

(defun
 core-logging--detect-column-alignments (headers rows)
 "Detect alignment for each column based on data types.
HEADERS is the list of column header strings.
ROWS is the list of data rows.
Returns a list of alignment symbols: \\='left or \\='right for each column.
Numeric columns (and their headers) get \\='right alignment."
 (let ((num-cols (length headers)))
   (mapcar
    (lambda (col-idx) (if (core-logging--column-is-numeric-p col-idx rows) 'right 'left))
    (number-sequence 0 (1- num-cols)))))

(defun
 core-logging--build-row (columns widths alignments)
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
 core-logging--build-border (widths type)
 "Build a horizontal border line with box-drawing characters.
WIDTHS is a list of column widths.
TYPE is \\='top, \\='middle, or \\='bottom.
Returns border string with appropriate box-drawing characters.

Examples:
  (core-logging--build-border \\='(5 3 4) \\='top)
  => \"┌───────┬─────┬──────┐\"
  (core-logging--build-border \\='(5 3 4) \\='middle)
  => \"├───────┼─────┼──────┤\"
  (core-logging--build-border \\='(5 3 4) \\='bottom)
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
 core-logging--build-total-row (headers rows total-spec)
 "Build total row data based on TOTAL-SPEC.
HEADERS is the list of column header strings.
ROWS is the list of data rows.
TOTAL-SPEC controls total row behavior:
  - nil: No total row (default)
  - \\='count-only: Show \"TOTAL: N\" in first column, \"-\" in others
  - (list of indices): Sum columns at indices, \"-\" for others, \"TOTAL\" in first
  - (list of names): Sum columns matching names, \"-\" for others, \"TOTAL\" in first
  - (function): Custom function (lambda (headers rows) ...) that returns total row data

Returns list of column values for total row, or nil if no total row.

Examples:
  (core-logging--build-total-row headers rows nil)
  => nil

  (core-logging--build-total-row headers rows \\='count-only)
  => (\"TOTAL: 5\" \"-\" \"-\" \"-\")

  (core-logging--build-total-row headers rows \\='(1 3))
  => (\"TOTAL\" \"15\" \"-\" \"42\")

  (core-logging--build-total-row headers rows \\='(\"Age\" \"Count\"))
  => (\"TOTAL\" \"15\" \"-\" \"42\")

  (core-logging--build-total-row headers rows (lambda (h r) (list \"Custom\" \"Total\")))
  => (\"Custom\" \"Total\")"
 (let ((num-cols (length headers)))
   (pcase total-spec
     ('nil nil)
     ('count-only (cons (format "TOTAL: %d" (length rows)) (make-list (1- num-cols) "-")))
     ((pred functionp) (funcall total-spec headers rows))
     ((pred listp)
      (let ((indices-to-sum
             (if
              (stringp (car total-spec))
              (mapcar
               (lambda (name) (cl-position name headers :test 'string=)) total-spec)
              total-spec)))
        (cons
         "TOTAL"
         (cl-loop
          for col-idx from 1 below num-cols collect
          (if
           (member col-idx indices-to-sum)
           (number-to-string
            (cl-loop for row in rows sum (string-to-number (format "%s" (nth col-idx row)))))
           "-"))))))))

(defun
 core-logging--detect-total-row-alignments (total-row)
 "Detect alignment for TOTAL-ROW based on data types.
TOTAL-ROW is a list of column values for the total row.
Returns a list of alignment symbols: \\='left or \\='right for each column.
Numeric columns get \\='right alignment, text columns get \\='left.
First column is always \\='left aligned (typically contains \"TOTAL\" label).
Numeric patterns recognized: integers, floats, and fractions (e.g., \"3/5\")."
 (let ((num-cols (length total-row)))
   (cl-loop
    for col-idx from 0 below num-cols collect
    (if
     (= col-idx 0) 'left
     (let ((value (format "%s" (nth col-idx total-row))))
       (if
        (and
         (not (string-empty-p (string-trim value)))
         (not (string= (string-trim value) "-"))
         (string-match-p "\\`[0-9]+\\(?:\\.[0-9]+\\|/[0-9]+\\)?\\'" (string-trim value)))
        'right 'left))))))

(defun
 core-logging-format-table (headers rows &optional total-spec)
 "Format HEADERS and ROWS as a box-drawing table.
HEADERS is a list of column header strings.
ROWS is a list of row data, where each row is a list of column values.
TOTAL-SPEC is an optional parameter controlling total row behavior:
  - nil: No total row (default)
  - \\='count-only: Show \"TOTAL: N\" in first column, \"-\" in others
  - (list of indices): Sum columns at indices, \"-\" for others, \"TOTAL\" in first
  - (list of names): Sum columns matching header names, \"-\" for others, \"TOTAL\" in first
  - (function): Custom function (lambda (headers rows) ...) that returns total row data

Returns a list of formatted strings with box-drawing characters.
Uses `core-logging-calculate-column-widths' for dynamic column sizing.
Automatically right-aligns numeric columns (both headers and data).

Examples:
  ;; No total row (default)
  (core-logging-format-table
   \\='(\"Name\" \"Age\" \"City\")
   \\='((\"Alice\" \"25\" \"NYC\")
     (\"Bob\" \"30\" \"SF\")))
  => Table without total row

  ;; Count-only total
  (core-logging-format-table
   \\='(\"Name\" \"Age\" \"City\")
   \\='((\"Alice\" \"25\" \"NYC\")
     (\"Bob\" \"30\" \"SF\"))
   \\='count-only)
  => Last row: │ TOTAL: 2 │ - │ - │

  ;; Sum specific columns by index
  (core-logging-format-table
   \\='(\"Name\" \"Age\" \"Score\")
   \\='((\"Alice\" \"25\" \"100\")
     (\"Bob\" \"30\" \"150\"))
   \\='(1 2))
  => Last row: │ TOTAL │ 55 │ 250 │

  ;; Sum specific columns by name
  (core-logging-format-table
   \\='(\"Name\" \"Age\" \"Score\")
   \\='((\"Alice\" \"25\" \"100\")
     (\"Bob\" \"30\" \"150\"))
   \\='(\"Age\" \"Score\"))
  => Last row: │ TOTAL │ 55 │ 250 │

  ;; Custom total row function
  (core-logging-format-table
   \\='(\"Name\" \"Count\" \"Value\")
   \\='((\"A\" \"10\" \"100\")
     (\"B\" \"20\" \"200\"))
   (lambda (headers rows)
     (list \"Custom\" (number-to-string (length rows)) \"Total\")))
  => Last row: │ Custom │ 2 │ Total │"
 (let* ((col-widths (core-logging-calculate-column-widths headers rows))
        (alignments (core-logging--detect-column-alignments headers rows))
        (lines nil))
   ;; Top border: ┌───┬───┬───┐
   (push (core-logging--build-border col-widths 'top) lines)
   ;; Header row: │ Col │ Col │ Col │
   (push (core-logging--build-row headers col-widths alignments) lines)
   ;; Header separator: ├───┼───┼───┤
   (push (core-logging--build-border col-widths 'middle) lines)
   ;; Data rows: │ Data │ Data │ Data │
   (dolist (row rows) (push (core-logging--build-row row col-widths alignments) lines))
   ;; Total row (if requested)
   (when-let ((total-row (core-logging--build-total-row headers rows total-spec)))
     ;; Total separator: ├───┼───┼───┤
     (push (core-logging--build-border col-widths 'middle) lines)
     ;; Total row: │ TOTAL │ ... │
     (let ((total-alignments (core-logging--detect-total-row-alignments total-row)))
       (push (core-logging--build-row total-row col-widths total-alignments) lines)))
   ;; Bottom border: └───┴───┴───┘
   (push (core-logging--build-border col-widths 'bottom) lines)
   (nreverse lines)))

(provide 'core-logging-tables)
;;; core-logging-tables.el ends here
