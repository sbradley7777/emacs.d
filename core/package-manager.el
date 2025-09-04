;;; package-manager.el --- Package System Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Package manager setup, repository configuration, and use-package initialization.
;;      This file establishes the foundation for package management.

(require 'core-constants)

(defvar config-load-start-time (current-time))
(message "🔄  Loading package-manager.el...")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package Repository Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'cl-lib)
(require 'package)

;; Enable both MELPA repositories for maximum package availability
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)

;; Set package archive priorities (higher number = higher priority)
;; Prefer stable packages, fallback to development versions
(setq
 package-archive-priorities
 `(("melpa-stable" . ,core-melpa-stable-priority)
   ("gnu" . ,core-gnu-priority)
   ("melpa" . ,core-melpa-priority)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package System Initialization
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package initialization - check if already initialized to prevent duplicate calls
(unless package--initialized (package-initialize))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Security Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Secure keyring management - pin keyring updates to GNU ELPA for security
(add-to-list 'package-pinned-packages '("gnu-elpa-keyring-update" . "gnu"))

;; Pin completion framework to stable version for reliability
(add-to-list 'package-pinned-packages '("corfu" . "melpa-stable"))

;; Enhanced security configuration for package verification
(setq
 package-check-signature 'allow-unsigned ; Verify signatures when available, allow unsigned
 package-unsigned-archives '("melpa")) ; Explicitly allow unsigned packages from MELPA

;; Ensure GNU ELPA keyring is available before installing other packages
;; This maintains security with signature verification
(unless
 (package-installed-p 'gnu-elpa-keyring-update)
 (when
  (network-responsive-p)
  (safe-package-refresh-with-timeout) ; Network-aware refresh
  (condition-case err
      (progn
       (package-install 'gnu-elpa-keyring-update)
       (message "🔐  GNU ELPA keyring updated for secure package verification"))
    (error
     (message "⚠️  Failed to install keyring update: %s" (error-message-string err))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Network-Aware Package Management
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package Content Management
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Network-aware package content refresh - only if network available and contents missing
(when
 (not package-archive-contents)
 (message "ℹ️  Package archive contents not loaded, determining loading strategy...")
 (message "ℹ️  Need metadata to activate packages and resolve dependencies")
 (if
  (network-responsive-p)
  (progn
   (message "📡  Network connectivity confirmed, proceeding with package refresh...")
   (safe-package-refresh-with-timeout))
  (progn
   (message "⚠️  Network connectivity unavailable")
   (message "ℹ️  Proceeding with offline mode - using any cached package data")
   (when
    (= (length package-archive-contents) 0)
    (message "⚠️  No package data available - some features may be limited")))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Use-Package Bootstrap and Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Install use-package if not already present with network-aware approach
(unless
 (package-installed-p 'use-package)
 (if
  (network-responsive-p)
  (progn
   (message "📦  Installing use-package...") (safe-package-refresh-with-timeout)
   (condition-case err
       (progn (package-install 'use-package) (message "✅  use-package installed successfully"))
     (error
      (message "❌  Failed to install use-package: %s" (error-message-string err)))))
  (message "⚠️  Network unavailable, use-package installation skipped")))

;; Configure use-package for optimal package management with fallback
(condition-case err
    (progn
     (eval-when-compile (require 'use-package))
     ;; Global use-package configuration
     (setq
      use-package-always-ensure t ; Always ensure packages are installed
      use-package-verbose t ; Show loading messages for debugging
      use-package-compute-statistics t ; Enable statistics collection
      use-package-minimum-reported-time core-use-package-minimum-reported-time) ; Report slow-loading packages
     (message "✅  use-package configured successfully"))
  (error
   (message "⚠️  use-package unavailable: %s" (error-message-string err))
   (message "ℹ️  Package-dependent features will be skipped")
   ;; Provide minimal fallback macro to prevent errors
   (defmacro
    use-package
    (name &rest args)
    "Minimal fallback when use-package unavailable."
    `(message "Skipping %s configuration (use-package unavailable)" ',name))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package Management Utilities
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 package-upgrade-all
 ()
 "Upgrade all installed packages to their latest versions."
 (interactive)
 (message "🔍  Checking for package upgrades...")
 (unless
  (network-responsive-p) (user-error "Network unavailable - cannot check for package upgrades"))
 (safe-package-refresh-with-timeout)
 (let ((upgradeable-packages '())
       (failed-packages '())
       (upgraded-count 0))
   ;; Find packages that have newer versions available
   (dolist
    (pkg package-alist)
    (let* ((pkg-desc (car pkg))
           (pkg-name (package-desc-name pkg-desc))
           (current-version (package-desc-version pkg-desc)))
      (when-let ((available-pkg (cadr (assq pkg-name package-archive-contents))))
        (let ((available-version (package-desc-version available-pkg)))
          (when
           (and
            available-version current-version (version-list-< current-version available-version))
           (push pkg-name upgradeable-packages))))))

   ;; Attempt to upgrade each package with error handling
   (if
    upgradeable-packages
    (progn
     (message
      "Found %d packages to upgrade: %s"
      (length upgradeable-packages)
      (mapconcat #'symbol-name upgradeable-packages ", "))
     (dolist
      (pkg upgradeable-packages)
      (condition-case err
          (progn
           (package-install pkg)
           (setq upgraded-count (1+ upgraded-count))
           (message "✅  Upgraded: %s" pkg))
        (error
         (push pkg failed-packages)
         (message "❌  Failed to upgrade %s: %s" pkg (error-message-string err)))))

     ;; Summary
     (message
      "Package upgrade complete: %d successful, %d failed" upgraded-count (length failed-packages))
     (when
      failed-packages
      (message "❌  Failed upgrades: %s" (mapconcat #'symbol-name failed-packages ", "))))
    (message "✅  All packages are up to date"))))

(defun
 package-cleanup-unused
 ()
 "Remove unused package dependencies."
 (interactive)
 (package-autoremove)
 (message "🧹  Cleaned up unused packages"))

;; Make this module available for loading with (require 'package-manager)
(provide 'package-manager)
;; Test hook execution with trailing spaces
(message
 "package-manager.el loaded (%.2fs)"
 (float-time (time-subtract (current-time) config-load-start-time)))
