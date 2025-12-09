;;; flymake-diagnostic-export.el --- Flymake Diagnostic Export to Text Files -*- lexical-binding: t -*-
;;; Commentary:
;; Export Flymake diagnostics to text files with mirrored directory structure.
;;
;; Exports create .txt files in /tmp/flymake_diagnostics/ with the full
;; source file path mirrored inside, making it easy to identify which
;; source file the diagnostics came from.
;;
;; Example:
;;   Source: /tmp/flymake_debug/test.c
;;   Export: /tmp/flymake_diagnostics/tmp/flymake_debug/test.c.txt

;;; Code:
(require 'flymake)
(require 'flymake-diagnostic-data)
(require 'core-table-utils)
(require 'logging-init)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defconst
 flymake-export-base-directory
 "/tmp/flymake_diagnostics/"
 "Base directory for Flymake diagnostic exports.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 flymake-export--count-error-codes (diagnostics)
 "Count occurrences of error codes in DIAGNOSTICS.
Returns an alist of (code . count) sorted by count descending.
Returns nil if no diagnostics have error codes."
 (let ((code-counts (make-hash-table :test 'equal))
       (has-codes nil))
   (dolist
    (diag diagnostics)
    (let ((code (flymake-diagnostic-extract-error-code diag)))
      (when
       (and code (not (string= code "-")))
       (setq has-codes t)
       (puthash code (1+ (gethash code code-counts 0)) code-counts))))
   (when
    has-codes
    (let ((result nil))
      (maphash (lambda (code count) (push (cons code count) result)) code-counts)
      (sort result (lambda (a b) (> (cdr a) (cdr b))))))))

(defun
 flymake-export--format-code-summary (diagnostics)
 "Format error code summary table for DIAGNOSTICS.
Returns list of table lines, or nil if no error codes present."
 (let ((code-counts (flymake-export--count-error-codes diagnostics)))
   (when
    code-counts
    (let* ((headers '("Error Code" "Count"))
           (rows
            (mapcar (lambda (pair) (list (car pair) (number-to-string (cdr pair)))) code-counts)))
      (core-table-format headers rows)))))

(defun
 flymake-export--create-mirrored-path (source-file)
 "Create mirrored export path for SOURCE-FILE.
Returns the full export path with directory structure mirrored from root.

Example:
  Source: /tmp/flymake_debug/test.c
  Export: /tmp/flymake_diagnostics/tmp/flymake_debug/test.c.txt"
 (let* ((absolute-path (expand-file-name source-file))
        (mirrored-path (concat flymake-export-base-directory (substring absolute-path 1) ".txt")))
   mirrored-path))

(defun
 flymake-export--ensure-directory
 (file-path)
 "Ensure directory exists for FILE-PATH, creating parent directories as needed."
 (let ((directory (file-name-directory file-path)))
   (unless (file-exists-p directory) (make-directory directory t))))

(defun
 flymake-export-current-buffer-diagnostics ()
 "Export current buffer's Flymake diagnostics to a text file.
Creates a formatted table with all diagnostics from the current buffer.
Saves to /tmp/flymake_diagnostics/<full-source-path>.txt with mirrored directory structure.

Columns: Line, Col, Type, Code, Backend, Message

Only works if Flymake is active in current buffer with a file."
 (interactive)
 (unless
  (and (boundp 'flymake-mode) flymake-mode) (user-error "Flymake is not active in current buffer"))
 (unless buffer-file-name (user-error "Buffer must be visiting a file"))
 (let* ((source-file buffer-file-name)
        (export-file (flymake-export--create-mirrored-path source-file))
        (buffer-name (buffer-name))
        (diagnostics (flymake-diagnostics))
        (headers '("Line" "Col" "Type" "Code" "Backend" "Message"))
        (rows (mapcar #'flymake-convert-diagnostic-to-row diagnostics))
        (table-lines (core-table-format headers rows))
        (summary-lines (flymake-export--format-code-summary diagnostics)))
   (flymake-export--ensure-directory export-file)
   (with-temp-file
    export-file
    (insert (format "Flymake Diagnostics for %s\n" buffer-name))
    (insert (format "Source: %s\n" source-file))
    (insert (format "Exported: %s\n\n" (format-time-string "%Y-%m-%d %H:%M:%S")))
    (when
     summary-lines
     (insert "Error Code Summary:\n")
     (dolist (line summary-lines) (insert line "\n"))
     (insert "\nDetailed Diagnostics:\n"))
    (dolist (line table-lines) (insert line "\n")))
   (logging-success "Exported %d diagnostics to %s" (length diagnostics) export-file)))

(defun
 flymake-export-all-buffers-diagnostics ()
 "Export Flymake diagnostics from all buffers to text files.
Creates separate .txt files for each buffer with diagnostics.
Each file is saved in /tmp/flymake_diagnostics/ with mirrored directory structure.

Only exports buffers that:
- Have flymake-mode active
- Are visiting a file
- Have at least one diagnostic"
 (interactive)
 (let ((exported-count 0)
       (total-diags 0))
   (dolist
    (buf (buffer-list))
    (with-current-buffer
     buf
     (when
      (and (boundp 'flymake-mode) flymake-mode buffer-file-name)
      (let ((diagnostics (flymake-diagnostics)))
        (when
         diagnostics
         (let* ((source-file buffer-file-name)
                (export-file (flymake-export--create-mirrored-path source-file))
                (buffer-name (buffer-name))
                (headers '("Line" "Col" "Type" "Code" "Backend" "Message"))
                (rows (mapcar #'flymake-convert-diagnostic-to-row diagnostics))
                (table-lines (core-table-format headers rows))
                (summary-lines (flymake-export--format-code-summary diagnostics)))
           (flymake-export--ensure-directory export-file)
           (with-temp-file
            export-file
            (insert (format "Flymake Diagnostics for %s\n" buffer-name))
            (insert (format "Source: %s\n" source-file))
            (insert (format "Exported: %s\n\n" (format-time-string "%Y-%m-%d %H:%M:%S")))
            (when
             summary-lines
             (insert "Error Code Summary:\n")
             (dolist (line summary-lines) (insert line "\n"))
             (insert "\nDetailed Diagnostics:\n"))
            (dolist (line table-lines) (insert line "\n")))
           (setq exported-count (1+ exported-count))
           (setq total-diags (+ total-diags (length diagnostics)))))))))
   (if
    (= exported-count 0) (user-error "No buffers with Flymake diagnostics found")
    (logging-success
     "Exported %d diagnostics from %d buffers to %s"
     total-diags
     exported-count
     flymake-export-base-directory))))

(provide 'flymake-diagnostic-export)
;;; flymake-diagnostic-export.el ends here
