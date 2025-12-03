;;; package-cache.el --- Package State Caching System -*- lexical-binding: t -*-
;;; Commentary:
;;      Package state caching for offline functionality and faster startup.
;;      Provides intelligent cache management with freshness validation.

;;; Code:
(require 'logging-init)
(require 'package)
(require 'pkg-system-metadata)

;; Declare external functions to suppress byte-compiler warnings
(declare-function package-activate-all "package" ())

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar
 pkg-system-cache-max-age (* 7 24 60 60) ; 7 days in seconds
 "Maximum age of package cache before considering it stale.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 pkg-system-cache-fresh-p () "Check if package cache exists and is recent enough to use."
 (let ((cache-info (pkg-system-read-cache-info)))
   (when
    (> (plist-get cache-info :timestamp) 0)
    (let ((cache-age
           (float-time
            (time-subtract (current-time) (seconds-to-time (plist-get cache-info :timestamp))))))
      (< cache-age pkg-system-cache-max-age)))))

(defun
 pkg-system-cache-save-state () "Cache current working package configuration to disk."
 (when
  (and
   package-archive-contents
   (> (length package-archive-contents) 10)) ; Sanity check
  (condition-case err
      (let ((cache-timestamp (float-time (current-time)))
            (package-count (length package-archive-contents)))
        (pkg-system-write-cache-info cache-timestamp package-count)
        (logging-info "Package state cached (%d packages)" package-count))
    (error
     (logging-warning "Failed to save package cache: %s" (error-message-string err))))))

(defun
 pkg-system-cache-load-cached-state () "Load cached package state using built-in package system."
 (let ((cache-info (pkg-system-read-cache-info)))
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
            (logging-info
             "Using cached package activation (%d packages, %.1f days old)"
             (length package-alist)
             (/ cache-age 86400)))))
      (error
       (logging-warning "Failed to load package cache: %s" (error-message-string err)))))))

(defun
 pkg-system--cache-clear ()
 "Clear the package metadata cache file.

Removes cached package information to force a fresh refresh from repositories
on the next package operation.  Useful when package metadata seems out of date
or corrupted."
 (interactive) (pkg-system-metadata-reset))
(provide 'pkg-system-cache)
;;; pkg-system-cache.el ends here
