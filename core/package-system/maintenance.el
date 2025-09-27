;;; maintenance.el --- Package Upgrade and Maintenance -*- lexical-binding: t -*-
;;; Commentary:
;;      Interactive package upgrade, cleanup, and maintenance utilities.
;;      Bulk operations with comprehensive error handling and network awareness.

(require 'core-constants)
(require 'package-system/network)
(require 'core-utils)
(require 'logging)

(core-utils-with-load-timing
 "maintenance.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Package Management Utilities
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  package-upgrade-all
  ()
  "Upgrade all installed packages to their latest versions."
  (interactive)
  (core-message-debug "Checking for package upgrades...")
  (unless
   (network-responsive-p)
   (core-message-error "Network unavailable - cannot check for package upgrades"))
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
            (core-utils-increment-counter upgraded-count)
            (core-message-success "Upgraded: %s" pkg))
         (error
          (push pkg failed-packages)
          (core-message-error "Failed to upgrade %s: %s" pkg (error-message-string err)))))

      ;; Summary
      (message
       "Package upgrade complete: %d successful, %d failed"
       upgraded-count
       (length failed-packages))
      (when
       failed-packages
       (core-message-error "Failed upgrades: %s" (mapconcat #'symbol-name failed-packages ", "))))
     (core-message-success "All packages are up to date"))))

 (defun
  package-cleanup-unused
  ()
  "Remove unused package dependencies."
  (interactive)
  (package-autoremove)
  (core-message-package "Cleaned up unused packages"))

 ;; Make this module available for loading with (require 'package-system/maintenance)
 (provide 'package-system/maintenance))
