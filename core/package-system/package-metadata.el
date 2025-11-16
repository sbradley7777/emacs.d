;;; package-metadata.el --- Package metadata persistence management -*- lexical-binding: t -*-
;;; Commentary:
;;      Centralized management of package system persistent metadata.
;;      Handles reading/writing of package refresh timestamps and cache information
;;      to a unified human-readable metadata file.

;;; Code:
(require 'core-constants)
(require 'core-logging)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Constants and Variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar
 package-metadata-file
 core-package-metadata-file
 "File to store all package system persistent metadata.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Utility Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 package-metadata-normalize-timestamp (timestamp)
 "Convert timestamp to human-readable format if needed.
TIMESTAMP can be a string (already human-readable), list (Emacs time format), or nil."
 (cond
  ;; Already human-readable
  ((stringp timestamp)
   timestamp)
  ;; Old Emacs time format - convert
  ((listp timestamp)
   (format-time-string "%Y-%m-%d %H:%M:%S" timestamp))
  ;; Nil or other - use current time
  (t
   (format-time-string "%Y-%m-%d %H:%M:%S"))))
(defun
 package-metadata-load-variables ()
 "Load metadata variables from file if it exists.
Returns t if file was loaded successfully, nil otherwise."
 (when
  (file-exists-p package-metadata-file)
  (condition-case err
      (progn (load package-metadata-file) t)
    (error
     (core-message-warning "Failed to load package metadata: %s" (error-message-string err))
     nil))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Refresh Timestamp Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 package-metadata-read-refresh-timestamp ()
 "Read the last package refresh timestamp from persistent storage.
Returns the timestamp as a float, or 0 if no previous check recorded."
 (package-metadata-load-variables)
 (if
  (boundp 'package-last-refresh-timestamp)
  (condition-case err
      (cond
       ;; Human-readable format
       ((stringp package-last-refresh-timestamp)
        (float-time (date-to-time package-last-refresh-timestamp)))
       ;; Legacy numeric format
       ((numberp package-last-refresh-timestamp)
        package-last-refresh-timestamp)
       ;; Unknown format
       (t
        (core-message-warning "Invalid refresh timestamp format, resetting to 0")
        0))
    (error
     (core-message-warning "Failed to parse refresh timestamp: %s" (error-message-string err))
     0))
  0))

(defun
 package-metadata-write-refresh-timestamp (timestamp)
 "Write the package refresh timestamp to persistent storage.
TIMESTAMP should be a float from (float-time (current-time))."
 (let ((human-readable (format-time-string "%Y-%m-%d %H:%M:%S" (seconds-to-time timestamp))))
   (package-metadata-save-all :refresh-timestamp human-readable)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Cache Information Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 package-metadata-read-cache-info ()
 "Read cache timestamp and count from persistent storage.
Returns a plist with :timestamp (as float) and :count, or defaults if not found."
 (package-metadata-load-variables)
 (let ((timestamp
        (when
         (boundp 'package-cache-timestamp)
         (cond
          ;; Human-readable format
          ((stringp package-cache-timestamp)
           (float-time (date-to-time package-cache-timestamp)))
          ;; Legacy Emacs time format
          ((listp package-cache-timestamp)
           (float-time package-cache-timestamp))
          ;; Legacy numeric format
          ((numberp package-cache-timestamp)
           package-cache-timestamp)
          (t
           0))))
       (count
        (when
         (boundp 'package-cache-count) (if (numberp package-cache-count) package-cache-count 0))))
   (list :timestamp (or timestamp 0) :count (or count 0))))
(defun
 package-metadata-write-cache-info (timestamp count)
 "Write cache timestamp and count to persistent storage.
TIMESTAMP should be a float from (float-time (current-time)).
COUNT should be the number of packages in the cache."
 (let ((human-readable (format-time-string "%Y-%m-%d %H:%M:%S" (seconds-to-time timestamp))))
   (package-metadata-save-all :cache-timestamp human-readable :cache-count count)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; File Management Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 package-metadata-save-all (&rest args)
 "Save all metadata to file with updated values.
ARGS is a plist of values to update: :refresh-timestamp, :cache-timestamp, :cache-count."
 (let* ((plist (apply #'list args))
        ;; Load current values or use defaults
        (current-refresh
         (if
          (package-metadata-load-variables)
          (package-metadata-normalize-timestamp
           (when (boundp 'package-last-refresh-timestamp) package-last-refresh-timestamp))
          nil))
        (current-cache-info (package-metadata-read-cache-info))
        ;; Use provided values or current values
        (refresh-ts (or (plist-get plist :refresh-timestamp) current-refresh))
        (cache-ts
         (or
          (plist-get plist :cache-timestamp)
          (package-metadata-normalize-timestamp
           (seconds-to-time (plist-get current-cache-info :timestamp)))))
        (cache-count (or (plist-get plist :cache-count) (plist-get current-cache-info :count))))

   (condition-case err
       (with-temp-file
        package-metadata-file
        (insert
         ";;; package-metadata.el --- Package management persistent metadata -*- lexical-binding: t -*-\n")
        (insert ";;;\n")
        (insert ";;; This file stores package system state and can be safely deleted to reset\n")
        (insert ";;; package cache and force fresh downloads from repositories.\n")
        (insert ";;;\n")
        (insert ";;; METADATA EXPLANATION:\n")
        (insert
         ";;; - package-last-refresh-timestamp: When package catalog/list was last downloaded from repositories\n")
        (insert
         ";;;   (runs package-refresh-contents to get latest available packages from MELPA, GNU ELPA, etc.)\n")
        (insert
         ";;; - package-cache-timestamp: When local package metadata cache file was created\n")
        (insert ";;; - package-cache-count: Number of packages available in cached catalog\n")
        (insert ";;;\n")
        (insert ";;; Generated automatically by package system - do not edit manually.\n")
        (insert "\n")
        (when
         refresh-ts (insert (format "(setq package-last-refresh-timestamp \"%s\")\n" refresh-ts)))
        (when cache-ts (insert (format "(setq package-cache-timestamp \"%s\")\n" cache-ts)))
        (when cache-count (insert (format "(setq package-cache-count %d)\n" cache-count)))
        (insert "\n")
        (insert ";;; package-metadata.el ends here\n"))
     (error
      (core-message-error "Failed to save package metadata: %s" (error-message-string err))))))
(defun
 package-metadata-reset () "Delete the metadata file to reset all package system state."
 (when
  (file-exists-p package-metadata-file)
  (condition-case err
      (progn
       (delete-file package-metadata-file)
       (core-message-success "Package metadata reset successfully"))
    (error
     (core-message-error "Failed to delete metadata file: %s" (error-message-string err))))))
(defun
 package-metadata-info () "Display current package metadata information."
 (if
  (file-exists-p package-metadata-file)
  (progn
   (package-metadata-load-variables)
   (let ((refresh-ts
          (when (boundp 'package-last-refresh-timestamp) package-last-refresh-timestamp))
         (cache-ts (when (boundp 'package-cache-timestamp) package-cache-timestamp))
         (cache-count (when (boundp 'package-cache-count) package-cache-count)))
     (core-message-package "Package Metadata:")
     (core-message-plain "    Last refresh: %s" (or refresh-ts "Never"))
     (core-message-plain "    Cache created: %s" (or cache-ts "Never"))
     (core-message-plain "    Package count: %s" (or cache-count "Unknown"))))
  (core-message-package "No package metadata found")))
(provide 'package-metadata)
;;; package-metadata.el ends here
