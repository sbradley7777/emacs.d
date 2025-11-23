;;; package-network.el --- Network-Aware Package Management -*- lexical-binding: t -*-
;;; Commentary:
;;      Network connectivity testing and timeout-protected package operations.
;;      Provides resilient package management with graceful network failure handling.
;;      Includes per-repository health checking and dynamic repository filtering.

;;; Code:
(require 'core-logging)
(require 'package-cache)
(require 'package-metadata)
(require 'url)
(require 'url-http)

;; External url-http variables
(defvar url-http-attempt-keepalives)
(defvar url-http-open-connections)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Customization Variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Configure url library for fail-fast behavior
(setq url-http-attempt-keepalives nil) ; Disable keepalives to prevent hanging connections

;; Initialize url-http-open-connections if needed
(unless
 (hash-table-p url-http-open-connections)
 (setq url-http-open-connections (make-hash-table :test 'equal)))

(defcustom
 package-repository-test-timeout 3
 "Timeout in seconds for testing individual repository connectivity.
Uses asynchronous retrieval to properly timeout even during TCP connection phase."
 :type 'integer
 :group 'package)

(defcustom
 package-refresh-timeout
 30
 "Timeout in seconds for overall package refresh operation."
 :type 'integer
 :group 'package)

(defcustom
 package-repository-cache-ttl 30
 "Time in seconds to cache repository health status.
After this period, repositories will be re-tested for availability."
 :type 'integer
 :group 'package)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar
 package-repository-health-cache nil
 "Alist of (url . (status . timestamp)) tracking repository health.
STATUS is t for available, nil for unavailable.
TIMESTAMP is the time of last test as returned by `current-time'.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Macros
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defmacro
 with-available-repositories (&rest body)
 "Execute BODY with `package-archives' temporarily set to only available repositories.
Tests repository connectivity and filters out unresponsive ones."
 `(let ((original-archives package-archives)
        (available-repos (package-network-get-available-repositories)))
    (unwind-protect
     (progn (setq package-archives available-repos) ,@body)
     (setq package-archives original-archives))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 package-network--lookup-repo-name (url)
 "Look up repository name for URL in `package-archives'.
Returns repository name or \"unknown\" if not found."
 (or (car (rassoc url package-archives)) "unknown"))

(defun
 package-network--elapsed-since (start-time)
 "Calculate seconds elapsed since START-TIME.
START-TIME should be from `current-time'."
 (float-time (time-subtract (current-time) start-time)))

(defun
 repository-cache-valid-p (url)
 "Check if cached health status for URL is still valid based on TTL.
Returns the cached status (t or nil) if valid, or nil if cache expired or missing."
 (let ((cached-entry (assoc url package-repository-health-cache)))
   (when
    cached-entry
    (let* ((status (cadr cached-entry))
           (timestamp (cddr cached-entry))
           (age (float-time (time-subtract (current-time) timestamp))))
      (when (< age package-repository-cache-ttl) status)))))

(defun
 update-repository-health-cache (url status)
 "Update health cache for URL with STATUS and current timestamp.
Also invalidates cache on successful operations (event-based invalidation)."
 (let ((timestamp (current-time)))
   (setq
    package-repository-health-cache
    (cons
     (cons url (cons status timestamp)) (assq-delete-all url package-repository-health-cache)))
   ;; Event-based invalidation: if any repo becomes available, invalidate all cached failures
   (when
    status
    (setq
     package-repository-health-cache
     (seq-filter (lambda (entry) (cadr entry)) package-repository-health-cache)))))

(defun
 package-network-test-url (repository-url &optional timeout)
 "Test if REPOSITORY-URL is responsive within TIMEOUT seconds.
Returns t if repository responds successfully, nil otherwise.
Uses cached result if available and fresh per `package-repository-cache-ttl'.
Uses asynchronous retrieval to properly handle TCP connection timeouts."
 (let ((cached-status (repository-cache-valid-p repository-url)))
   (if
    cached-status
    (progn
     (core-message-debug
      "Using cached status for %s: %s" repository-url (if cached-status "available" "unavailable"))
     cached-status)
    (let* ((start-time (current-time))
           (timeout-seconds (or timeout package-repository-test-timeout))
           (deadline (time-add (current-time) timeout-seconds))
           (status nil)
           (done nil)
           (buf nil))
      (condition-case err
          (with-timeout
           (timeout-seconds
            (core-message-debug
             "Repository %s timed out after %ds" repository-url timeout-seconds)
            (when (buffer-live-p buf) (ignore-errors (kill-buffer buf))) nil)
           ;; Use asynchronous url-retrieve to avoid TCP connection hang bug (Emacs bug #71295)
           (setq
            buf
            (url-retrieve
             repository-url
             (lambda (status-arg) (setq done t) (setq status (not (plist-get status-arg :error))))
             nil ; cbargs
             t)) ; silent
           ;; Wait for async process to complete or timeout
           (when
            buf
            (let ((proc (get-buffer-process buf)))
              ;; Use short intervals (0.1s) to check process output until done or deadline
              (while
               (and (not done) (process-live-p proc) (time-less-p (current-time) deadline))
               (accept-process-output proc 0.1))
              (when
               (and done status)
               (core-message-debug
                "Repository %s responsive (%.2fs)"
                repository-url
                (package-network--elapsed-since start-time)))
              ;; Clean up buffer if still alive
              (when (buffer-live-p buf) (ignore-errors (kill-buffer buf))))))
        (error
         (core-message-debug "Repository %s failed: %s" repository-url (error-message-string err))
         (when (buffer-live-p buf) (ignore-errors (kill-buffer buf)))
         (setq status nil)))
      (update-repository-health-cache repository-url status)
      status))))

(defun
 package-network-get-available-repositories ()
 "Return list of available repositories from `package-archives'.
Tests each repository and returns only those that are responsive.
Results are cached per `package-repository-cache-ttl'."
 (let ((available-repos nil)
       (unavailable-repos nil))
   (dolist
    (archive package-archives)
    (let* ((name (car archive))
           (url (cdr archive))
           (responsive (package-network-test-url url)))
      (if responsive (push archive available-repos) (push name unavailable-repos))))
   (when
    unavailable-repos
    (core-message-warning
     "Excluding %d unavailable repository(ies): %s"
     (length unavailable-repos)
     (mapconcat 'identity (reverse unavailable-repos) ", ")))
   (if
    available-repos
    (progn
     (core-message-info "Using %d available repository(ies)" (length available-repos))
     (reverse available-repos))
    (progn (core-message-error "No package repositories are currently available") nil))))

(defun
 network-responsive-p ()
 "Quick network connectivity check with diagnostic feedback.
Tests if at least one package repository is available."
 (core-message-debug "Testing connectivity to package repositories...")
 (let ((available-repos (package-network-get-available-repositories)))
   (if
    available-repos
    (progn
     (core-message-success
      "Network connectivity confirmed - %d repository(ies) available" (length available-repos))
     t)
    (progn (core-message-error "No package repositories are accessible") nil))))

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
               (package-network--elapsed-since start-time)
               timeout-seconds)
              (core-message-info "Using any cached package data available"))
             (package-refresh-contents)
             (core-message-success
              "Package refresh completed in %.2fs (%d packages available)"
              (package-network--elapsed-since start-time)
              (length package-archive-contents))
             ;; Event-based cache invalidation on success
             (package-repositories-clear-cache))
          (error
           (core-message-error
            "Package refresh failed after %.2fs: %s"
            (package-network--elapsed-since start-time)
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
   ((and (not package-archive-contents) (network-responsive-p))
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

(provide 'package-network)
;;; package-network.el ends here
