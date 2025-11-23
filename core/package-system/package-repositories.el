;;; package-repositories.el --- Repository Configuration and Security -*- lexical-binding: t -*-
;;; Commentary:
;;      Package repository setup, archive priorities, and security policies.
;;      Centralizes trust policies, signature verification, and repository management.

;;; Code:
(require 'core-constants)
(require 'core-logging)
(require 'package-network)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package Repository Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'cl-lib)
(require 'package)

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
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
    (network-responsive-p) (safe-package-refresh-with-timeout)
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
 package-repositories-test-connectivity
 ()
 "Test network connectivity to all package repositories individually.
Reports status and response time for each repository."
 (interactive)
 (core-message-info "Testing connectivity to all package repositories...")
 (core-message-plain "")
 (let ((total-repos (length package-archives))
       (available-count 0))
   (dolist
    (archive package-archives)
    (let* ((name (car archive))
           (url (cdr archive))
           (start-time (current-time))
           (responsive (package-network-test-url url)))
      (if
       responsive
       (progn
        (core-message-success
         "%s (%s) - responsive (%.2fs)" name url (package-network--elapsed-since start-time))
        (setq available-count (1+ available-count)))
       (core-message-error "%s (%s) - unavailable or timed out" name url))))
   (core-message-plain "")
   (if
    (> available-count 0)
    (core-message-success "Summary: %d/%d repositories available" available-count total-repos)
    (core-message-error "Summary: No repositories are currently accessible"))))

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
          (age (package-network--elapsed-since timestamp))
          (archive-name (package-network--lookup-repo-name url)))
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
  (network-responsive-p)
  (progn
   (safe-package-refresh-with-timeout)
   (save-package-state)
   (core-message-success "Package refresh and cache update completed"))
  (core-message-error "Cannot refresh packages - network unavailable")))

(provide 'package-repositories)
;;; package-repositories.el ends here
