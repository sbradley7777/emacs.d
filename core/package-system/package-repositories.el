;;; package-repositories.el --- Repository Configuration and Security -*- lexical-binding: t -*-
;;; Commentary:
;;      Package repository setup, archive priorities, and security policies.
;;      Centralizes trust policies, signature verification, and repository management.
;;      Manages repository health checking with caching for optimal performance.

;;; Code:
(require 'core-constants)
(require 'core-logging)
(require 'package-network-utils)
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
 package-repository-test-timeout 3
 "Timeout in seconds for testing individual repository connectivity.
Uses asynchronous retrieval to properly timeout even during TCP connection phase."
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
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 package-repositories--lookup-name (url)
 "Look up repository name for URL in `package-archives'.
Returns repository name or \"unknown\" if not found."
 (or (car (rassoc url package-archives)) "unknown"))

(defun
 package-repositories--cache-valid-p (url)
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
 package-repositories--update-health-cache (url status)
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
 package-repositories-test-url (repository-url &optional timeout)
 "Test if REPOSITORY-URL is responsive within TIMEOUT seconds.
Returns t if repository responds successfully, nil otherwise.
Uses cached result if available and fresh per `package-repository-cache-ttl'.
Uses asynchronous retrieval to properly handle TCP connection timeouts."
 (let ((cached-status (package-repositories--cache-valid-p repository-url)))
   (if
    cached-status
    (progn
     (core-message-debug
      "Using cached status for %s: %s" repository-url (if cached-status "available" "unavailable"))
     cached-status)
    (let* ((timeout-seconds (or timeout package-repository-test-timeout))
           (status (network-utils-test-url repository-url timeout-seconds)))
      (package-repositories--update-health-cache repository-url status)
      status))))

(defun
 package-repositories-get-available ()
 "Return list of available repositories from `package-archives'.
Tests each repository and returns only those that are responsive.
Results are cached per `package-repository-cache-ttl'."
 (let ((available-repos nil)
       (unavailable-repos nil))
   (dolist
    (archive package-archives)
    (let* ((name (car archive))
           (url (cdr archive))
           (start-time (current-time))
           (responsive (package-repositories-test-url url)))
      (if
       responsive
       (progn
        (core-message-debug
         "Repository %s responsive (%.2fs)" url (network-utils--elapsed-since start-time))
        (push archive available-repos))
       (push name unavailable-repos))))
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
 package-repositories-responsive-p ()
 "Quick network connectivity check with diagnostic feedback.
Tests if at least one package repository is available."
 (core-message-debug "Testing connectivity to package repositories...")
 (let ((available-repos (package-repositories-get-available)))
   (if
    available-repos
    (progn
     (core-message-success
      "Network connectivity confirmed - %d repository(ies) available" (length available-repos))
     t)
    (progn (core-message-error "No package repositories are accessible") nil))))

(defun
 package-repositories-ensure-keyring ()
 "Ensure GNU ELPA keyring is available before installing other packages.
This maintains security with signature verification.
Should be called during initialization after package system is configured."
 (unless
  (package-installed-p 'gnu-elpa-keyring-update)
  (if
   noninteractive (core-message-batch-skip "keyring update check")
   (when
    (package-repositories-responsive-p) (safe-package-refresh-with-timeout)
    (condition-case err
        (progn
         (package-install 'gnu-elpa-keyring-update)
         (core-message-success "GNU ELPA keyring updated for secure package verification"))
      (error
       (core-message-warning
        "Failed to install keyring update: %s" (error-message-string err))))))))

(defun
 package-repositories-clear-cache
 ()
 "Clear repository health cache, forcing fresh connectivity test.
Useful when network conditions change or to manually trigger re-testing."
 (interactive)
 (setq package-repository-health-cache nil)
 (core-message-info "Repository health cache cleared - will re-test on next operation"))

(defun
 diagnostics-show-repositories-connectivity ()
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
           (responsive (package-repositories-test-url url))
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
           (table-lines (core-logging-format-table headers formatted-rows))
           (row-count (length formatted-rows))
           (col-widths (core-logging-calculate-column-widths headers formatted-rows))
           (total-row
            (list
             "Total"
             (number-to-string row-count)
             (format "%d/%d" available-count total-repos)
             (format time-format-string total-time)))
           (total-alignments '(left right right right)))
      (core-message-diagnostic
       "Package Repository Connectivity"
       (append
        (butlast table-lines)
        (list
         (core-logging--build-border col-widths 'middle)
         (core-logging--build-row total-row col-widths total-alignments)
         (core-logging--build-border col-widths 'bottom)))))
    (core-message-diagnostic
     "Package Repository Connectivity" (list "No repositories configured")))))

(defun
 package-repositories-list-status ()
 "Display current health cache status for all repositories.
Shows last test time and result for each repository."
 (interactive) (core-message-info "Repository Health Status:") (core-message-plain "")
 (if
  (null package-repository-health-cache)
  (core-message-info "No cached repository status (cache is empty)")
  (dolist
   (entry package-repository-health-cache)
   (let* ((url (car entry))
          (status (cadr entry))
          (timestamp (cddr entry))
          (age (network-utils--elapsed-since timestamp))
          (archive-name (package-repositories--lookup-name url)))
     (if
      status
      (core-message-success "%s (%s) - available (tested %.1fs ago)" archive-name url age)
      (core-message-error "%s (%s) - unavailable (tested %.1fs ago)" archive-name url age)))))
 (core-message-plain "") (core-message-info "Cache TTL: %d seconds" package-repository-cache-ttl))

(defun
 package-repositories-refresh-archives
 ()
 "Force a package archive refresh regardless of cache status.
Clears repository health cache and re-tests all repositories."
 (interactive)
 (core-message-loading "Forcing package refresh...")
 (package-repositories-clear-cache)
 (if
  (package-repositories-responsive-p)
  (progn
   (safe-package-refresh-with-timeout)
   (save-package-state)
   (core-message-success "Package refresh and cache update completed"))
  (core-message-error "Cannot refresh packages - network unavailable")))

(provide 'package-repositories)
;;; package-repositories.el ends here
