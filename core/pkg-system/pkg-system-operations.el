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
    (pkg-system-cache-save-state))

   ;; Fresh cache available - skip network operations
   ((and (not package-archive-contents) (pkg-system-cache-fresh-p))
    (core-message-info "Fresh package cache found, skipping network refresh...")
    (core-message-info "Using existing package installations (fast startup mode)"))

   ;; Network available - refresh and cache for future
   ((and (not package-archive-contents) (pkg-system-responsive-p))
    (core-message-info "At least one repository available, proceeding with package refresh...")
    (pkg-system-refresh-with-timeout)
    (when package-archive-contents (pkg-system-cache-save-state)))

   ;; Network down, stale cache available - inform user
   ((and (not package-archive-contents) (> (plist-get (pkg-system-read-cache-info) :timestamp) 0))
    (core-message-warning "Network unavailable, using offline mode...")
    (pkg-system-cache-load-cached-state)
    (core-message-info "Consider refreshing when network returns"))

   ;; No cache, no network - minimal functionality mode
   ((not package-archive-contents)
    (core-message-warning "No package data available (no cache, no network)")
    (core-message-info "Emacs will start with limited package functionality")))))

(defun
 pkg-system-operations-refresh-archives
 ()
 "Force a package archive refresh regardless of cache status.
Clears repository health cache and re-tests all repositories."
 (interactive)
 (core-message-loading "Forcing package refresh...")
 (pkg-system-repositories-clear-cache)
 (if
  (pkg-system-responsive-p)
  (progn
   (pkg-system-refresh-with-timeout)
   (pkg-system-cache-save-state)
   (core-message-success "Package refresh and cache update completed"))
  (core-message-error "Cannot refresh packages - network unavailable")))

(provide 'pkg-system-operations)
;;; pkg-system-operations.el ends here
