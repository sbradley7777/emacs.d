;;; package-cache.el --- Package State Caching System -*- lexical-binding: t -*-
;;; Commentary:
;;      Package state caching for offline functionality and faster startup.
;;      Provides intelligent cache management with freshness validation.

;;; Code:
(require 'core-logging)
(require 'package)
(require 'package-metadata)

;; Declare external functions to suppress byte-compiler warnings
(declare-function package-activate-all "package" ())

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package State Caching Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar
 package-cache-max-age (* 7 24 60 60) ; 7 days in seconds
 "Maximum age of package cache before considering it stale.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Cache Management Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 package-cache-fresh-p () "Check if package cache exists and is recent enough to use."
 (let ((cache-info (package-metadata-read-cache-info)))
   (when
    (> (plist-get cache-info :timestamp) 0)
    (let ((cache-age
           (float-time
            (time-subtract (current-time) (seconds-to-time (plist-get cache-info :timestamp))))))
      (< cache-age package-cache-max-age)))))
(defun
 save-package-state () "Cache current working package configuration to disk."
 (when
  (and
   package-archive-contents
   (> (length package-archive-contents) 10)) ; Sanity check
  (condition-case err
      (let ((cache-timestamp (float-time (current-time)))
            (package-count (length package-archive-contents)))
        (package-metadata-write-cache-info cache-timestamp package-count)
        (core-message-info "Package state cached (%d packages)" package-count))
    (error
     (core-message-warning "Failed to save package cache: %s" (error-message-string err))))))
(defun
 load-cached-package-state () "Load cached package state using built-in package system."
 (let ((cache-info (package-metadata-read-cache-info)))
   (when
    (> (plist-get cache-info :timestamp) 0)
    (condition-case err
        (progn
         ;; Use package system's built-in caching instead of custom serialization
         (package-activate-all)
         (when
          (> (length package-alist) 0)
          (let ((cache-age
                 (float-time
                  (time-subtract
                   (current-time) (seconds-to-time (plist-get cache-info :timestamp))))))
            (core-message-info
             "Using cached package activation (%d packages, %.1f days old)"
             (length package-alist)
             (/ cache-age 86400)))))
      (error
       (core-message-warning "Failed to load package cache: %s" (error-message-string err))))))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Cache Utility Functions
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  package-cache-info
  ()
  "Display information about the package cache."
  (interactive)
  (package-metadata-info))
 (defun
  package-cache-clear ()
  "Clear the package metadata cache file.

Removes cached package information to force a fresh refresh from repositories
on the next package operation. Useful when package metadata seems out of date
or corrupted."
  (interactive) (package-metadata-reset)))
(provide 'package-cache)
;;; package-cache.el ends here
