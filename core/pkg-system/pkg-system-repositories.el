;;; package-repositories.el --- Repository Configuration and Security -*- lexical-binding: t -*-
;;; Commentary:
;;      Package repository setup, archive priorities, and security policies.
;;      Centralizes trust policies, signature verification, and repository management.
;;      Manages repository health checking with caching for optimal performance.

;;; Code:
(require 'core-constants)
(require 'logging-init)
(require 'pkg-system-cache)
(require 'pkg-system-metadata)
(require 'pkg-system-network-utils)
(require 'cl-lib)
(require 'package)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package Repository Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Configure package repositories explicitly
(setq
 package-archives
 '(("gnu" . "https://elpa.gnu.org/packages/")
   ("nongnu" . "https://elpa.nongnu.org/nongnu/")
   ("melpa" . "https://melpa.org/packages/")))

;; Set package archive priorities (higher number = higher priority)
;; MELPA has highest priority to get latest versions with bug fixes
;; GNU/NonGNU ELPA serve as fallback for packages not in MELPA
(setq
 package-archive-priorities
 `(("melpa" . ,core-melpa-priority) ; Highest priority for latest versions
   ("nongnu" . ,core-nongnu-priority) ; Fallback for packages not in MELPA
   ("gnu" . ,core-gnu-priority))) ; Fallback for official packages
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Security Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Secure keyring management - pin keyring updates to GNU ELPA for security
(add-to-list 'package-pinned-packages '("gnu-elpa-keyring-update" . "gnu"))

;; Enhanced security configuration for package verification
(setq
 package-check-signature 'allow-unsigned ; Verify signatures when available, allow unsigned
 package-unsigned-archives '("melpa")) ; Explicitly allow unsigned packages from MELPA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Customization Variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defcustom
 pkg-system-repository-test-timeout 3
 "Timeout in seconds for testing individual repository connectivity.
Uses asynchronous retrieval to properly timeout even during TCP connection phase."
 :type 'integer
 :group 'package)

(defcustom
 pkg-system-repository-cache-ttl 30
 "Time in seconds to cache repository health status.
After this period, repositories will be re-tested for availability."
 :type 'integer
 :group 'package)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar
 pkg-system-repository-health-cache nil
 "Alist of (url . (status . timestamp)) tracking repository health.
STATUS is t for available, nil for unavailable.
TIMESTAMP is the time of last test as returned by `current-time'.")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 pkg-system--repositories-lookup-name (url)
 "Look up repository name for URL in `package-archives'.
Returns repository name or \"unknown\" if not found."
 (or (car (rassoc url package-archives)) "unknown"))

(defun
 pkg-system--repositories-cache-valid-p (url)
 "Check if cached health status for URL is still valid based on TTL.
Returns the cached status (t or nil) if valid, or nil if cache expired or missing."
 (let ((cached-entry (assoc url pkg-system-repository-health-cache)))
   (when
    cached-entry
    (let* ((status (cadr cached-entry))
           (timestamp (cddr cached-entry))
           (age (float-time (time-subtract (current-time) timestamp))))
      (when (< age pkg-system-repository-cache-ttl) status)))))

(defun
 pkg-system--repositories-update-health-cache (url status)
 "Update health cache for URL with STATUS and current timestamp.
Also invalidates cache on successful operations (event-based invalidation)."
 (let ((timestamp (current-time)))
   (setq
    pkg-system-repository-health-cache
    (cons
     (cons url (cons status timestamp)) (assq-delete-all url pkg-system-repository-health-cache)))
   ;; Event-based invalidation: if any repo becomes available, invalidate all cached failures
   (when
    status
    (setq
     pkg-system-repository-health-cache
     (seq-filter (lambda (entry) (cadr entry)) pkg-system-repository-health-cache)))))

(defun
 pkg-system-repositories-test-url (repository-url &optional timeout)
 "Test if REPOSITORY-URL is responsive within TIMEOUT seconds.
Returns t if repository responds successfully, nil otherwise.
Uses cached result if available and fresh per `pkg-system-repository-cache-ttl'.
Uses asynchronous retrieval to properly handle TCP connection timeouts."
 (let ((cached-status (pkg-system--repositories-cache-valid-p repository-url)))
   (if
    cached-status
    (progn
     (logging-debug
      "Using cached status for %s: %s" repository-url (if cached-status "available" "unavailable"))
     cached-status)
    (let* ((timeout-seconds (or timeout pkg-system-repository-test-timeout))
           (status (network-utils-test-url repository-url timeout-seconds)))
      (pkg-system--repositories-update-health-cache repository-url status)
      status))))

(defun
 pkg-system-get-available ()
 "Return list of available repositories from `package-archives'.
Tests each repository and returns only those that are responsive.
Results are cached per `pkg-system-repository-cache-ttl'."
 (let ((available-repos nil)
       (unavailable-repos nil))
   (dolist
    (archive package-archives)
    (let* ((name (car archive))
           (url (cdr archive))
           (start-time (current-time))
           (responsive (pkg-system-repositories-test-url url)))
      (if
       responsive
       (progn
        (logging-debug
         "Repository %s responsive (%.2fs)" url (pkg-system--network-elapsed-since start-time))
        (push archive available-repos))
       (push name unavailable-repos))))
   (when
    unavailable-repos
    (logging-warning
     "Excluding %d unavailable repository(ies): %s"
     (length unavailable-repos)
     (mapconcat 'identity (reverse unavailable-repos) ", ")))
   (if
    available-repos
    (progn
     (logging-info "Using %d available repository(ies)" (length available-repos))
     (reverse available-repos))
    (progn (logging-error "No package repositories are currently available") nil))))

(defun
 pkg-system-responsive-p ()
 "Quick network connectivity check with diagnostic feedback.
Tests if at least one package repository is available."
 (logging-debug "Testing connectivity to package repositories...")
 (let ((available-repos (pkg-system-get-available)))
   (if
    available-repos
    (progn
     (logging-success
      "Network connectivity confirmed - %d repository(ies) available" (length available-repos))
     t)
    (progn (logging-error "No package repositories are accessible") nil))))

(defun
 pkg-system-repositories-clear-cache
 ()
 "Clear repository health cache, forcing fresh connectivity test.
Useful when network conditions change or to manually trigger re-testing."
 (interactive)
 (setq pkg-system-repository-health-cache nil)
 (logging-info "Repository health cache cleared - will re-test on next operation"))

(provide 'pkg-system-repositories)
;;; pkg-system-repositories.el ends here
