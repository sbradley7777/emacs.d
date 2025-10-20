;;; core-log-writer.el --- Log File Writing and Rotation -*- lexical-binding: t -*-

;;; Commentary:
;; This file provides functionality for writing the Messages buffer to files
;; with automatic log rotation support.


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Logging Constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defconst core-log-max-files 5 "Maximum number of rotated log files to keep.")
(defconst
 core-log-directory (expand-file-name "log" emacs-local-dir) "Directory for storing log files.")
(defconst core-messages-log-file "messages.log" "Base name for messages log file.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Log Directory Management
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun
 core-ensure-log-directory
 ()
 "Ensure the log directory exists, creating it if necessary."
 (core-utils-ensure-directory core-log-directory))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Log File Rotation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun
 core-rotate-log-files (base-filename)
 "Rotate log files, keeping up to `core-log-max-files' files.
BASE-FILENAME is the base name without directory."
 (let ((log-dir (expand-file-name core-log-directory))
       (base-path (expand-file-name base-filename core-log-directory)))
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
           (core-message-warning
            "Failed to rotate log file %s: %s" from-file (error-message-string err)))))))
    ;; Move current log to .1
    (condition-case err
        (rename-file base-path (format "%s.1" base-path) t)
      (error
       (core-message-warning
        "Failed to rotate current log file: %s" (error-message-string err)))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Messages Buffer Logging
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun
 core-save-messages-log () "Save Messages buffer to log file with rotation and timestamp."
 (condition-case err
     (progn
      (core-ensure-log-directory)
      (let ((log-file (expand-file-name core-messages-log-file core-log-directory)))
        ;; Rotate existing log files
        (core-rotate-log-files core-messages-log-file)
        ;; Save current Messages buffer contents
        (with-current-buffer
         "*Messages*"
         (let ((contents (buffer-string)))
           (with-temp-file
            log-file
            (insert contents)
            (goto-char (point-max))
            (insert (format "\n;; Session ended: %s\n" (current-time-string))))))
        (core-message-success "Messages log saved to %s" log-file)))
   (error
    (core-message-error "Failed to save messages log: %s" (error-message-string err)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Hook Setup
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(add-hook 'kill-emacs-hook 'core-save-messages-log)
(core-message-config "Message logging configured with %d file rotation" core-log-max-files)

(provide 'core-log-writer)

;;; core-log-writer.el ends here
