;;; pkg-system-diagnostics.el --- Package System Diagnostics -*- lexical-binding: t -*-
;;; Commentary:
;;      Diagnostic and reporting commands for package system troubleshooting.
;;      Provides comprehensive status reports for repositories and package status.

;;; Code:
(require 'logging-init)
(require 'core-table-utils)
(require 'pkg-system-repositories)
(require 'pkg-system-metadata)
(require 'pkg-system-network-utils)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 pkg-system--diagnostics-get-installed-count
 ()
 "Return count of installed packages."
 (if (boundp 'package-activated-list) (length package-activated-list) 0))

(defun
 pkg-system--diagnostics-get-upgrades-count ()
 "Return count of packages with available updates.
Returns nil if package-archive-contents is not loaded."
 (when
  (and (boundp 'package-archive-contents) package-archive-contents)
  (length (package-menu--find-upgrades))))

(defun
 pkg-system--diagnostics-show-repositories
 ()
 "Display package repository connectivity as a table (non-interactive)."
 (let ((headers '("Name" "URL" "Status" "Time (s)"))
       (rows nil)
       (times nil)
       (total-time 0.0)
       (available-count 0)
       (total-repos (length package-archives)))
   (dolist
    (archive package-archives)
    (let* ((name (car archive))
           (url (cdr archive))
           (start-time (current-time))
           (responsive (pkg-system-repositories-test-url url))
           (elapsed (pkg-system--network-elapsed-since start-time))
           (status (if responsive "online" "offline")))
      (when
       responsive
       (setq available-count (1+ available-count))
       (setq total-time (+ total-time elapsed)))
      (push elapsed times)
      (push (list name url status elapsed) rows)))
   (if
    rows
    (let* ((all-times (cons total-time times))
           (max-int-width
            (apply
             'max (mapcar (lambda (time) (length (number-to-string (truncate time)))) all-times)))
           (time-width (+ max-int-width 3))
           (time-format-string (format "%%%d.2f" time-width))
           (formatted-rows
            (mapcar
             (lambda
              (row)
              (list (nth 0 row) (nth 1 row) (nth 2 row) (format time-format-string (nth 3 row))))
             (nreverse rows)))
           (row-count (length formatted-rows))
           (total-spec
            (lambda
             (headers rows)
             (list
              "Total"
              (number-to-string row-count)
              (format "%d/%d" available-count total-repos)
              (format time-format-string total-time)))))
      (logging-diagnostic
       "Package Repository Connectivity" (core-table-format headers formatted-rows total-spec)))
    (logging-diagnostic "Package Repository Connectivity" (list "No repositories configured")))))

(defun
 pkg-system--diagnostics-show-package-status
 ()
 "Display package installation and update status as a table (non-interactive)."
 (let* ((installed (pkg-system--diagnostics-get-installed-count))
        (upgrades (pkg-system--diagnostics-get-upgrades-count))
        (headers '("Package Type" "Count"))
        (rows
         (list
          (list "Installed Packages" (number-to-string installed))
          (list "Updates Available" (if upgrades (number-to-string upgrades) "Unknown")))))
   (logging-diagnostic "Package Status" (core-table-format headers rows))))

(defun
 pkg-system--diagnostics-show-metadata
 ()
 "Display package metadata and cache information as a table (non-interactive)."
 (if
  (file-exists-p pkg-system-metadata-file)
  (progn
   (pkg-system-load-variables)
   (let* ((refresh-ts
           (when (boundp 'package-last-refresh-timestamp) package-last-refresh-timestamp))
          (cache-ts (when (boundp 'package-cache-timestamp) package-cache-timestamp))
          (headers '("Operation" "Timestamp"))
          (rows
           (list
            (list "Last Refresh" (or refresh-ts "Never"))
            (list "Cache Created" (or cache-ts "Never")))))
     (logging-diagnostic "Package Metadata" (core-table-format headers rows))))
  (logging-diagnostic "Package Metadata" (list "No package metadata found"))))

(defun
 diagnostics-show-pkg-system
 ()
 "Display comprehensive package system diagnostics.
Shows repository connectivity, package status, and metadata information."
 (interactive)
 (logging-info "=== Package System Diagnostics ===")
 (logging-plain "")
 (pkg-system--diagnostics-show-repositories)
 (logging-plain "")
 (pkg-system--diagnostics-show-package-status)
 (logging-plain "")
 (pkg-system--diagnostics-show-metadata))

(provide 'pkg-system-diagnostics)
;;; pkg-system-diagnostics.el ends here
