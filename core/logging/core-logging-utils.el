;;; core-logging-utils.el --- Log File Writing and Rotation Utilities -*- lexical-binding: t -*-
;;; Commentary:
;; Generic log file writing and rotation utilities.
;; Provides shared functions for all buffer logging implementations.

;;; Code:
(require 'core-constants)
(require 'core-utils)
(require 'core-logging)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 logging--rotate-log-files (base-filename directory)
 "Rotate log files in DIRECTORY, keeping up to `core-log-max-files' files.
BASE-FILENAME is the base name without directory path."
 (let ((base-path (expand-file-name base-filename directory)))
   (when
    (file-exists-p base-path)
    ;; Move existing numbered files up
    (dotimes
     (i (1- core-log-max-files))
     (let ((from-file (format "%s.%d" base-path (- core-log-max-files i 1)))
           (to-file (format "%s.%d" base-path (- core-log-max-files i))))
       (when
        (file-exists-p from-file)
        (condition-case err
            (rename-file from-file to-file t)
          (error
           (logging-warning
            "Failed to rotate log file %s: %s" from-file (error-message-string err)))))))
    ;; Move current log to .1
    (condition-case err
        (rename-file base-path (format "%s.1" base-path) t)
      (error
       (logging-warning "Failed to rotate current log file: %s" (error-message-string err)))))))

(defun
 core-save-buffer-to-log (buffer-name log-filename directory &optional footer-fn)
 "Save BUFFER-NAME contents to log file with rotation.
LOG-FILENAME is the base filename (e.g., \\='messages.log\\=').
DIRECTORY is the target directory path.
Optional FOOTER-FN is called to insert footer content before saving.
Returns the full path to the saved log file, or nil on error."
 (condition-case err
     (progn
      ;; Ensure directory exists
      (unless (file-directory-p directory) (make-directory directory t))
      ;; Rotate existing log files
      (logging--rotate-log-files log-filename directory)
      ;; Save buffer contents
      (let ((log-file (expand-file-name log-filename directory)))
        (with-current-buffer
         buffer-name
         (let ((contents (buffer-string)))
           (with-temp-file
            log-file (insert contents)
            ;; Call optional footer function
            (when footer-fn (goto-char (point-max)) (funcall footer-fn)))))
        log-file))
   (error
    (logging-error "Failed to save %s to log: %s" buffer-name (error-message-string err))
    nil)))

(provide 'core-logging-utils)
;;; core-logging-utils.el ends here
