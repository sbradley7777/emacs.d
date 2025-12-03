;;; package-operations.el --- High-Level Package Operations -*- lexical-binding: t -*-
;;; Commentary:
;;      High-level package refresh, state management, and operation orchestration.
;;      Provides resilient package management with graceful network failure handling.
;;      Orchestrates repository management and network utilities for complex operations.

;;; Code:
(require 'core-logging)
(require 'pkg-system-cache)
(require 'pkg-system-metadata)
(require 'pkg-system-network-utils)
(require 'pkg-system-repositories)
(require 'pkg-system-refresh)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 pkg-system-operations-manage-state
 ()
 "Intelligently manage package state with hierarchical caching strategy."
 ;; Batch mode: Skip all network operations, use installed packages only
 (if
  noninteractive
  (progn
   (logging-batch-skip "network operations" "using %d installed packages" (length package-alist))
   ;; CRITICAL: Verify packages are installed (first-time setup check)
   (unless
    (> (length package-alist) 0)
    (logging-error "No packages installed - cannot run in batch mode")
    (logging-error "First-time setup required:")
    (logging-error "  1. Run Emacs interactively to install packages")
    (logging-error "  2. Wait for package installation to complete")
    (logging-error "  3. Then run batch mode operations (linting, testing)")
    (error "Batch mode requires packages to be installed first")))
  ;; Interactive mode: Full package management logic
  (logging-info "Determining optimal package loading strategy...")
  (cond
   ;; Package contents already loaded - cache for future offline use
   ((and package-archive-contents (> (length package-archive-contents) 10))
    (logging-info "Package contents already loaded, updating cache...")
    (pkg-system-cache-save-state))

   ;; Fresh cache available - skip network operations
   ((and (not package-archive-contents) (pkg-system-cache-fresh-p))
    (logging-info "Fresh package cache found, skipping network refresh...")
    (logging-info "Using existing package installations (fast startup mode)"))

   ;; Network available - refresh and cache for future
   ((and (not package-archive-contents) (pkg-system-responsive-p))
    (logging-info "At least one repository available, proceeding with package refresh...")
    (pkg-system-refresh-with-timeout)
    (when package-archive-contents (pkg-system-cache-save-state)))

   ;; Network down, stale cache available - inform user
   ((and (not package-archive-contents) (> (plist-get (pkg-system-read-cache-info) :timestamp) 0))
    (logging-warning "Network unavailable, using offline mode...")
    (pkg-system-cache-load-cached-state)
    (logging-info "Consider refreshing when network returns"))

   ;; No cache, no network - minimal functionality mode
   ((not package-archive-contents)
    (logging-warning "No package data available (no cache, no network)")
    (logging-info "Emacs will start with limited package functionality")))))

(defun
 pkg-system-operations-refresh-archives ()
 "Force a package archive refresh regardless of cache status.
Clears repository health cache and re-tests all repositories."
 (interactive) (logging-loading "Forcing package refresh...") (pkg-system-repositories-clear-cache)
 (if
  (pkg-system-responsive-p)
  (progn
   (pkg-system-refresh-with-timeout)
   (pkg-system-cache-save-state)
   (logging-success "Package refresh and cache update completed"))
  (logging-error "Cannot refresh packages - network unavailable")))

(provide 'pkg-system-operations)
;;; pkg-system-operations.el ends here
