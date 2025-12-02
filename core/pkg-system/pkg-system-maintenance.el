;;; package-maintenance.el --- Package Upgrade and Maintenance -*- lexical-binding: t -*-
;;; Commentary:
;;      Interactive package upgrade, cleanup, and maintenance utilities.
;;      Bulk operations with comprehensive error handling and network awareness.

;;; Code:
(require 'core-constants)
(require 'core-logging)
(require 'core-utils)
(require 'pkg-system-operations)
(require 'pkg-system-repositories)
(require 'pkg-system-metadata)
(require 'pkg-system-refresh)
(defvar pkg-system-packages-all) ; Forward declaration - defined in core-packages.el

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 pkg-system--maintenance-upgrade-all ()
 "Upgrade all installed packages to their latest available versions.

Checks for updates across all configured repositories and upgrades packages
that have newer versions available.  Requires network connectivity.
Shows summary of upgraded packages or reports if no upgrades are available."
 (interactive) (core-message-debug "Checking for package upgrades...")
 (unless
  (pkg-system-responsive-p)
  (core-message-error "Network unavailable - cannot check for package upgrades"))
 (pkg-system-refresh-with-timeout)
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
      "Package upgrade complete: %d successful, %d failed" upgraded-count (length failed-packages))
     (when
      failed-packages
      (core-message-error "Failed upgrades: %s" (mapconcat #'symbol-name failed-packages ", "))))
    (core-message-success "All packages are up to date"))))

(defun
 pkg-system-maintenance-cleanup ()
 "Clean up unused packages and reset package metadata cache.
Removes orphaned package dependencies using `package-autoremove' and resets metadata."
 (interactive)
 (let ((cleanup-count 0))
   (core-message-package "Starting package cleanup...")

   ;; Step 1: Remove unused dependencies using built-in package-autoremove
   (core-message-loading "Removing unused package dependencies...")
   (condition-case err
       (progn
        ;; Use pkg-system-packages-all as wanted packages if package-selected-packages is empty
        (let ((package-selected-packages (or package-selected-packages pkg-system-packages-all))
              (before-count (length package-alist)))

          ;; Override confirmation prompts to auto-accept
          (cl-letf (((symbol-function 'y-or-n-p) (lambda (&rest _) t))
                    ((symbol-function 'yes-or-no-p) (lambda (&rest _) t)))
            (package-autoremove))

          ;; Calculate removed count
          (setq cleanup-count (- before-count (length package-alist)))
          (if
           (> cleanup-count 0)
           (core-message-success
            "Removed %d unused package%s" cleanup-count (if (> cleanup-count 1) "s" ""))
           (core-message-success "No unused packages found"))))
     (error
      (core-message-error "Package cleanup failed: %s" (error-message-string err))))

   ;; Step 2: Reset package metadata cache
   (core-message-loading "Resetting package metadata cache...")
   (condition-case err
       (progn
        (require 'pkg-system-metadata)
        (when (fboundp 'pkg-system-metadata-reset) (pkg-system-metadata-reset))
        (core-message-success "Package metadata cache reset"))
     (error
      (core-message-warning "Metadata reset failed: %s" (error-message-string err))))

   ;; Summary
   (core-message-success
    "Cleanup complete: removed %d package%s, metadata reset"
    cleanup-count
    (if (> cleanup-count 1) "s" ""))))

(defun
 pkg-system-check-weekly-updates ()
 "Check for package update once per week during interactive sessions.
Automatically check for package update once per week during interactive Emacs sessions.
This provides awareness of available updates without automatically installing them.

How it works:
- Runs only during interactive sessions (not batch mode)
- Checks if 7 days have passed since last package list refresh (persistent across sessions)
- Refreshes package contents from repositories (MELPA, GNU ELPA, etc.)
- Notifies user if updates are available but does NOT install them
- User can run \\[pkg-system-ui-show-upgrades] for details or \\[package-list-packages] to install

Benefits:
- Stay informed about available updates (like the doom-themes fix we just applied)
- Maintains stability by requiring manual approval before installing updates
- Prevents surprise breakage from automatic updates
- Weekly frequency avoids slowing down daily startup times
- Persistent storage prevents duplicate checks across Emacs restarts"
 (let ((last-check-timestamp (pkg-system-read-refresh-timestamp))
       (days-since-last-check
        (/
         (float-time
          (time-subtract (current-time) (seconds-to-time (pkg-system-read-refresh-timestamp))))
         (* 24 60 60))))
   (if
    (and
     ;; Check if more than 7 days have passed since last refresh
     (>
      (float-time (time-subtract (current-time) (seconds-to-time last-check-timestamp)))
      (* 7 24 60 60)) ; 7 days in seconds
     ;; Only during interactive sessions, not batch mode
     (not noninteractive)
     ;; Only if network is available
     (pkg-system-responsive-p))
    ;; Perform weekly check
    (progn
     (core-message-package "Checking for package updates (weekly check)...")
     (core-message-debug "Configured repositories: %s" (mapcar #'car package-archives))
     ;; Refresh package contents with timeout protection
     (condition-case err
         (progn
          (let ((refresh-successful nil))
            (with-timeout
             (core-package-refresh-timeout
              (core-message-warning "Package update check timed out - skipping")
              (setq refresh-successful nil))
             (package-refresh-contents) (setq refresh-successful t))
            (if
             refresh-successful
             (progn
              (core-message-success
               "Package refresh completed successfully - contacted %d repositories"
               (length package-archives))
              ;; Check what packages have available updates
              (let ((upgrades (package-menu--find-upgrades)))
                (if
                 upgrades
                 (core-message-package
                  "Found %d package updates available. Run M-x pkg-system-ui-show-upgrades for details."
                  (length upgrades))
                 (core-message-package
                  "No package updates available - all packages are up to date.")))
              ;; Only update timestamp after EVERYTHING completed successfully
              (pkg-system-write-refresh-timestamp (float-time (current-time))))
             (core-message-warning "Package refresh incomplete - will retry next startup"))))
       (error
        (core-message-error "Package refresh failed: %s" (error-message-string err))
        ;; Still mark as checked to prevent repeated attempts
        (pkg-system-write-refresh-timestamp (float-time (current-time))))))
    ;; Skip check and inform user
    (when
     (not noninteractive)
     (core-message-package
      "Skipping package check (%.1f days since last check, checking weekly)"
      days-since-last-check)))))
(provide 'pkg-system-maintenance)
;;; pkg-system-maintenance.el ends here
