;;; package-diagnostics.el --- Package System Diagnostics -*- lexical-binding: t -*-
;;; Commentary:
;;      Diagnostic and reporting commands for package system troubleshooting.
;;      Provides comprehensive status reports for repositories, cache, and metadata.

;;; Code:
(require 'core-logging)
(require 'core-logging-tables)
(require 'pkg-system-repositories)
(require 'pkg-system-metadata)
(require 'pkg-system-network-utils)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 pkg-system-diagnostics-show-repositories-connectivity ()
 "Display package repository connectivity diagnostics as a table.
Shows status, response time, and availability for each configured repository."
 (interactive)
 (let ((headers '("Name" "URL" "Status" "Time (s)"))
       (rows nil)
       (times nil)
       (total-time 0.0)
       (available-count 0)
       (total-repos (length package-archives)))
   ;; Test each repository and collect data
   (dolist
    (archive package-archives)
    (let* ((name (car archive))
           (url (cdr archive))
           (start-time (current-time))
           (responsive (pkg-system-repositories-test-url url))
           (elapsed (network-utils--elapsed-since start-time))
           (status (if responsive "online" "offline")))
      (when
       responsive
       (setq available-count (1+ available-count))
       (setq total-time (+ total-time elapsed)))
      (push elapsed times)
      (push (list name url status elapsed) rows)))
   ;; Build table with total row
   (if
    rows
    (let* ( ;; Add total time to times list for width calculation
           (all-times (cons total-time times))
           ;; Find max integer part width for decimal alignment
           (max-int-width
            (apply
             'max (mapcar (lambda (time) (length (number-to-string (truncate time)))) all-times)))
           ;; Total width: max-int-width + 1 (decimal point) + 2 (decimal places)
           (time-width (+ max-int-width 3))
           ;; Build format string dynamically (Emacs format doesn't support %*)
           (time-format-string (format "%%%d.2f" time-width))
           ;; Format all time values with consistent padding for decimal alignment
           (formatted-rows
            (mapcar
             (lambda
              (row)
              (list (nth 0 row) (nth 1 row) (nth 2 row) (format time-format-string (nth 3 row))))
             (nreverse rows)))
           (row-count (length formatted-rows))
           ;; Custom total row function
           (total-spec
            (lambda
             (headers rows)
             (list
              "Total"
              (number-to-string row-count)
              (format "%d/%d" available-count total-repos)
              (format time-format-string total-time)))))
      (core-message-diagnostic
       "Package Repository Connectivity"
       (core-logging-format-table headers formatted-rows total-spec)))
    (core-message-diagnostic
     "Package Repository Connectivity" (list "No repositories configured")))))

(defun
 pkg-system-diagnostics-show-repository-cache
 ()
 "Display current health cache status for all repositories.
Shows last test time and result for each repository."
 (interactive)
 (core-message-info "Repository Health Status:")
 (core-message-plain "")
 (if
  (null pkg-system-repository-health-cache)
  (core-message-info "No cached repository status (cache is empty)")
  (dolist
   (entry pkg-system-repository-health-cache)
   (let* ((url (car entry))
          (status (cadr entry))
          (timestamp (cddr entry))
          (age (network-utils--elapsed-since timestamp))
          (archive-name (pkg-system-repositories--lookup-name url)))
     (if
      status
      (core-message-success "%s (%s) - available (tested %.1fs ago)" archive-name url age)
      (core-message-error "%s (%s) - unavailable (tested %.1fs ago)" archive-name url age)))))
 (core-message-plain "")
 (core-message-info "Cache TTL: %d seconds" pkg-system-repository-cache-ttl))

(defun
 pkg-system-diagnostics-show-metadata-info
 ()
 "Display current package metadata information."
 (interactive)
 (if
  (file-exists-p pkg-system-metadata-file)
  (progn
   (pkg-system-metadata-load-variables)
   (let ((refresh-ts
          (when (boundp 'package-last-refresh-timestamp) package-last-refresh-timestamp))
         (cache-ts (when (boundp 'package-cache-timestamp) package-cache-timestamp))
         (cache-count (when (boundp 'package-cache-count) package-cache-count)))
     (core-message-package "Package Metadata:")
     (core-message-plain "    Last refresh: %s" (or refresh-ts "Never"))
     (core-message-plain "    Cache created: %s" (or cache-ts "Never"))
     (core-message-plain "    Package count: %s" (or cache-count "Unknown"))))
  (core-message-package "No package metadata found")))

(defun
 pkg-system-diagnostics-show-cache-info
 ()
 "Display information about the package cache."
 (interactive)
 (pkg-system-diagnostics-show-metadata-info))

(defun
 pkg-system-diagnostics-show-system-status
 ()
 "Display comprehensive package system diagnostics.
Shows repository connectivity, cache status, and metadata information."
 (interactive)
 (core-message-info "=== Package System Diagnostics ===")
 (core-message-plain "")
 (pkg-system-diagnostics-show-repositories-connectivity)
 (core-message-plain "")
 (pkg-system-diagnostics-show-repository-cache)
 (core-message-plain "")
 (pkg-system-diagnostics-show-metadata-info))

(provide 'pkg-system-diagnostics)
;;; pkg-system-diagnostics.el ends here
