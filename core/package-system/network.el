;;; network.el --- Network-Aware Package Management -*- lexical-binding: t -*-
;;; Commentary:
;;      Network connectivity testing and timeout-protected package operations.
;;      Provides resilient package management with graceful network failure handling.

(require 'core-constants)
(require 'package-system/cache)
(require 'package-system/metadata)
(require 'core-utils)
(require 'url)

(core-utils-with-load-timing
 "network.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Network Connectivity Testing
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  network-responsive-p
  ()
  "Quick network connectivity check with diagnostic feedback."
  (message "🔍  Testing connectivity to ELPA repositories...")
  (message "ℹ️  This determines if packages can be downloaded or updated")
  (let ((start-time (current-time))
        (test-url "https://elpa.gnu.org")
        (timeout-seconds 3))
    (condition-case err
        (with-timeout
         (timeout-seconds
          (message "❌  ELPA connectivity test timed out after %ds" timeout-seconds) nil)
         (url-retrieve-synchronously test-url nil nil timeout-seconds)
         (let ((elapsed (float-time (time-subtract (current-time) start-time))))
           (message "✅  ELPA connectivity confirmed (%.2fs)" elapsed)
           t))
      (error
       (let ((elapsed (float-time (time-subtract (current-time) start-time))))
         (message "❌  ELPA connectivity failed after %.2fs: %s" elapsed (error-message-string err))
         nil)))))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Timeout-Protected Package Operations
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  safe-package-refresh-with-timeout
  ()
  "Refresh package contents with comprehensive diagnostic feedback."
  (message "📦  Refreshing package archive contents...")
  (let ((start-time (current-time))
        (timeout-seconds 15)
        (archive-count (length package-archives)))
    (message
     "ℹ️  Contacting %d package archives to refresh metadata: %s"
     archive-count
     (mapconcat (lambda (archive) (cdr archive)) package-archives ", "))
    (message "ℹ️  This updates available package lists and dependency information")
    (condition-case err
        (with-timeout
         (timeout-seconds
          (let ((elapsed (float-time (time-subtract (current-time) start-time))))
            (message
             "❌  Package refresh timed out after %.1fs (limit: %ds)" elapsed timeout-seconds)
            (message "ℹ️  Using any cached package data available")))
         (package-refresh-contents)
         (let ((elapsed (float-time (time-subtract (current-time) start-time)))
               (packages-count (length package-archive-contents)))
           (message
            "✅  Package refresh completed in %.2fs (%d packages available)"
            elapsed
            packages-count)))
      (error
       (let ((elapsed (float-time (time-subtract (current-time) start-time))))
         (message "❌  Package refresh failed after %.2fs: %s" elapsed (error-message-string err))
         (message "ℹ️  Will attempt to use cached package data if available"))))))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Smart Package State Management
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  smart-package-state-management
  ()
  "Intelligently manage package state with hierarchical caching strategy."
  (message "ℹ️  Determining optimal package loading strategy...")
  (cond
   ;; Package contents already loaded - cache for future offline use
   ((and package-archive-contents (> (length package-archive-contents) 10))
    (message "ℹ️  Package contents already loaded, updating cache...")
    (save-package-state))

   ;; Fresh cache available - skip network operations
   ((and (not package-archive-contents) (package-cache-fresh-p))
    (message "ℹ️  Fresh package cache found, skipping network refresh...")
    (message "ℹ️  Using existing package installations (fast startup mode)"))

   ;; Network available - refresh and cache for future
   ((and (not package-archive-contents) (network-responsive-p))
    (message "📡  Network connectivity confirmed, refreshing and caching...")
    (safe-package-refresh-with-timeout)
    (save-package-state))

   ;; Network down, stale cache available - inform user
   ((and
     (not package-archive-contents)
     (> (plist-get (package-metadata-read-cache-info) :timestamp) 0))
    (message "⚠️  Network unavailable, using offline mode...")
    (load-cached-package-state)
    (message "ℹ️  Consider refreshing when network returns"))

   ;; No cache, no network - minimal functionality mode
   ((not package-archive-contents)
    (message "⚠️  No package data available (no cache, no network)")
    (message "ℹ️  Emacs will start with limited package functionality"))))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Network Utility Functions
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  package-test-connectivity () "Test network connectivity to package repositories." (interactive)
  (if
   (network-responsive-p)
   (message "✅  Network connectivity to package repositories confirmed")
   (message "❌  Network connectivity to package repositories failed")))

 (defun
  package-force-refresh
  ()
  "Force a package refresh regardless of cache status."
  (interactive)
  (message "🔄  Forcing package refresh...")
  (if
   (network-responsive-p)
   (progn
    (safe-package-refresh-with-timeout)
    (save-package-state)
    (message "✅  Package refresh and cache update completed"))
   (message "❌  Cannot refresh packages - network unavailable")))

 ;; Make this module available for loading with (require 'package-system/network)
 (provide 'package-system/network))
