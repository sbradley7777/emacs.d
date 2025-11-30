;;; package-operations.el --- High-Level Package Operations -*- lexical-binding: t -*-
;;; Commentary:
;;      High-level package refresh, state management, and operation orchestration.
;;      Provides resilient package management with graceful network failure handling.
;;      Orchestrates repository management and network utilities for complex operations.

;;; Code:
(require 'core-logging)
(require 'package-cache)
(require 'package-metadata)
(require 'package-network-utils)
(require 'package-repositories)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Customization Variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defcustom
 package-refresh-timeout
 30
 "Timeout in seconds for overall package refresh operation."
 :type 'integer
 :group 'package)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Macros
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defmacro
 with-available-repositories (&rest body)
 "Execute BODY with `package-archives' temporarily set to only available repositories.
Tests repository connectivity and filters out unresponsive ones."
 `(let ((original-archives package-archives)
        (available-repos (package-repositories-get-available)))
    (unwind-protect
     (progn (setq package-archives available-repos) ,@body)
     (setq package-archives original-archives))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 safe-package-refresh-with-timeout ()
 "Refresh package contents with comprehensive diagnostic feedback.
Only contacts responsive repositories to prevent hanging on offline repos."
 (core-message-package "Refreshing package archive contents...")
 (let ((start-time (current-time))
       (timeout-seconds package-refresh-timeout))
   (with-available-repositories
    (let ((archive-count (length package-archives)))
      (if
       (= archive-count 0)
       (core-message-error "No repositories available - cannot refresh package contents")
       (progn
        (core-message-info
         "Contacting %d package archive(s) to refresh metadata: %s"
         archive-count
         (mapconcat (lambda (archive) (car archive)) package-archives ", "))
        (core-message-info "This updates available package lists and dependency information")
        (condition-case err
            (with-timeout
             (timeout-seconds
              (core-message-error
               "Package refresh timed out after %.1fs (limit: %ds)"
               (network-utils--elapsed-since start-time)
               timeout-seconds)
              (core-message-info "Using any cached package data available"))
             (package-refresh-contents)
             (core-message-success
              "Package refresh completed in %.2fs (%d packages available)"
              (network-utils--elapsed-since start-time)
              (length package-archive-contents))
             ;; Event-based cache invalidation on success
             (package-repositories-clear-cache))
          (error
           (core-message-error
            "Package refresh failed after %.2fs: %s"
            (network-utils--elapsed-since start-time)
            (error-message-string err))
           (core-message-info "Will attempt to use cached package data if available")))))))))

(defun
 smart-package-state-management
 ()
 "Intelligently manage package state with hierarchical caching strategy."
 ;; Batch mode: Skip all network operations, use installed packages only
 (if
  noninteractive
  (progn
   (core-message-batch-skip
    "network operations" "using %d installed packages" (length package-alist))
   ;; CRITICAL: Verify packages are installed (first-time setup check)
   (unless
    (> (length package-alist) 0)
    (core-message-error "No packages installed - cannot run in batch mode")
    (core-message-error "First-time setup required:")
    (core-message-error "  1. Run Emacs interactively to install packages")
    (core-message-error "  2. Wait for package installation to complete")
    (core-message-error "  3. Then run batch mode operations (linting, testing)")
    (error "Batch mode requires packages to be installed first")))
  ;; Interactive mode: Full package management logic
  (core-message-info "Determining optimal package loading strategy...")
  (cond
   ;; Package contents already loaded - cache for future offline use
   ((and package-archive-contents (> (length package-archive-contents) 10))
    (core-message-info "Package contents already loaded, updating cache...")
    (save-package-state))

   ;; Fresh cache available - skip network operations
   ((and (not package-archive-contents) (package-cache-fresh-p))
    (core-message-info "Fresh package cache found, skipping network refresh...")
    (core-message-info "Using existing package installations (fast startup mode)"))

   ;; Network available - refresh and cache for future
   ((and (not package-archive-contents) (package-repositories-responsive-p))
    (core-message-info "At least one repository available, proceeding with package refresh...")
    (safe-package-refresh-with-timeout)
    (when package-archive-contents (save-package-state)))

   ;; Network down, stale cache available - inform user
   ((and
     (not package-archive-contents)
     (> (plist-get (package-metadata-read-cache-info) :timestamp) 0))
    (core-message-warning "Network unavailable, using offline mode...")
    (load-cached-package-state)
    (core-message-info "Consider refreshing when network returns"))

   ;; No cache, no network - minimal functionality mode
   ((not package-archive-contents)
    (core-message-warning "No package data available (no cache, no network)")
    (core-message-info "Emacs will start with limited package functionality")))))

(provide 'package-operations)
;;; package-operations.el ends here
