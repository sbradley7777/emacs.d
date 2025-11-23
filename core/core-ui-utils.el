;;; core-ui-utils.el --- UI and Window Management Utilities -*- lexical-binding: t -*-
;;; Commentary:
;; Utility functions for window management, buffer finding, and UI operations.

;;; Code:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 core-ui-utils-format-table (headers rows)
 "Format HEADERS and ROWS as an aligned table with separators.
HEADERS is a list of column header strings.
ROWS is a list of row data, where each row is a list of column values.

Returns a list of formatted strings (header, separator, and data rows).

Example:
  (core-ui-utils-format-table
   \\='(\"Name\" \"Age\" \"City\")
   \\='((\"Alice\" \"25\" \"NYC\")
     (\"Bob\" \"30\" \"SF\")
     (\"Charlie\" \"35\" \"LA\")))

Returns:
  (\"Name     Age  City\"
   \"───────  ───  ────\"
   \"Alice    25   NYC\"
   \"Bob      30   SF\"
   \"Charlie  35   LA\")"
 (let* ((num-cols (length headers))
        (col-widths
         (mapcar
          (lambda
           (col-idx)
           (max
            (length (nth col-idx headers))
            (apply 'max (mapcar (lambda (row) (length (format "%s" (nth col-idx row)))) rows))))
          (number-sequence 0 (1- num-cols))))
        (format-str (mapconcat (lambda (width) (format "%%-%ds" width)) col-widths "  "))
        (lines nil))
   ;; Header
   (push (apply 'format format-str headers) lines)
   ;; Separator
   (push
    (apply 'format format-str (mapcar (lambda (width) (make-string width ?─)) col-widths)) lines)
   ;; Rows
   (dolist (row rows) (push (apply 'format format-str row) lines))
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
