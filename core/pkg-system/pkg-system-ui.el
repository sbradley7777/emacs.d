;;; package-ui.el --- Interactive Package Management UI -*- lexical-binding: t -*-
;;; Commentary:
;;      User-facing interfaces for package browsing, searching, and management.
;;      Provides interactive commands for discovering and managing packages.

;;; Code:
(require 'core-constants)
(require 'core-logging)
(require 'core-user-interaction-utils)
(require 'pkg-system-operations)
(require 'pkg-system-repositories)

;; Declare external functions to suppress byte-compiler warnings
(declare-function package-upgrade "package" (pkg &optional dont-select))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 pkg-system-ui-show-installed ()
 "Show installed packages with clear status labels and update information.
Packages are labeled as either \='Installed (by User)\=' or \='Dependency\='.
Shows available version and indicates if updates are available."
 (interactive)
 (let ((buf (get-buffer-create "*Installed Packages*"))
       (packages-with-updates '()))

   ;; Always refresh package archive contents to ensure accurate update information
   (when
    (pkg-system-responsive-p) (core-message-package "Refreshing package archive contents...")
    (condition-case err
        (with-timeout
         (core-package-refresh-timeout
          (core-message-warning "Package refresh timed out - using cached data"))
         (package-refresh-contents)
         (core-message-success "Package archive refreshed successfully"))
      (error
       (core-message-warning
        "Failed to refresh package contents: %s" (error-message-string err)))))
   (with-current-buffer
    buf (setq buffer-read-only nil) (erase-buffer)

    ;; Collect packages with updates
    (dolist
     (pkg (mapcar #'car package-alist))
     (let* ((installed-desc (cadr (assq pkg package-alist)))
            (installed-version (package-desc-version installed-desc))
            (available-desc (cadr (assq pkg package-archive-contents)))
            (available-version (when available-desc (package-desc-version available-desc))))
       (when
        (and available-version (version-list-< installed-version available-version))
        (message
         "There is an update for package %s. The current version is \"%s\" and updated version is available \"%s\""
         pkg
         (package-version-join installed-version)
         (package-version-join available-version))
        (push pkg packages-with-updates))))

    ;; Show update button if updates are available
    (when
     packages-with-updates
     (insert
      (format
       "%d package update%s available. "
       (length packages-with-updates)
       (if (> (length packages-with-updates) 1) "s" "")))
     (insert-button
      "[Update All]" 'action
      (lambda
       (_)
       (when
        (yes-or-no-p
         (format
          "Update %d package%s? "
          (length packages-with-updates)
          (if (> (length packages-with-updates) 1) "s" "")))
        ;; Upgrade packages
        (dolist (pkg packages-with-updates) (package-upgrade pkg))
        ;; Reload package state (suppress activation warnings)
        (let ((inhibit-message t))
          (package-initialize))
        (core-message-success "Updated %d packages" (length packages-with-updates))
        (sit-for 1)
        (pkg-system-ui-show-installed))))
     (insert "\n\n"))

    ;; Insert table header
    (insert
     (format
      "%-40s %-20s %-18s %-22s %s\n"
      "Package"
      "Installed"
      "Update Available"
      "Status"
      "Description"))
    (insert (make-string 127 ?-) "\n")

    ;; Insert package list
    (dolist
     (pkg (sort (mapcar #'car package-alist) #'string<))
     (let* ((desc (cadr (assq pkg package-alist)))
            (installed-version (package-desc-version desc))
            (available-desc (cadr (assq pkg package-archive-contents)))
            (available-version (when available-desc (package-desc-version available-desc)))
            (summary (package-desc-summary desc))
            (status (if (memq pkg package-selected-packages) "Installed (by User)" "Dependency"))
            (update-str
             (cond
              ((not available-version)
               "N/A")
              ((version-list-< installed-version available-version)
               "*")
              (t
               ""))))
       (insert
        (format
         "%-40s %-20s %-18s %-22s %s\n"
         (symbol-name pkg)
         (package-version-join installed-version)
         update-str
         status
         (or summary "")))))

    (goto-char (point-min)) (setq buffer-read-only t) (help-mode))
   (switch-to-buffer buf)))

(defun
 pkg-system-ui-search ()
 "Search for packages by name or keyword in available repositories.

Prompts for a search term and displays matching packages from all configured
package repositories.  Shows package descriptions and installation status.
Useful for discovering new packages or finding alternatives."
 (interactive)
 (let ((search-term (core-user-read-string "Search packages: ")))
   (when
    (and search-term (not (string-empty-p search-term)))
    ;; Use package-show-package-list with keywords parameter to avoid async refresh issues
    (package-show-package-list t (list search-term)))))

(defun
 pkg-system--ui-safe-refresh-and-check (timeout-seconds)
 "Safely refresh package contents and return available upgrades.
Returns a list of (PKG-NAME INSTALLED-DESC AVAILABLE-DESC) or nil if failed/no upgrades.
TIMEOUT-SECONDS specifies how long to wait before timing out."
 (when
  (pkg-system-responsive-p)
  (condition-case err
      (progn
       (with-timeout
        (timeout-seconds (core-message-warning "Package update check timed out"))
        (package-refresh-contents))
       ;; Manually find packages with updates (same logic as show-installed-packages)
       (let ((upgrades '()))
         (dolist
          (pkg (mapcar #'car package-alist))
          (let* ((installed-desc (cadr (assq pkg package-alist)))
                 (installed-version (package-desc-version installed-desc))
                 (available-desc (cadr (assq pkg package-archive-contents)))
                 (available-version (when available-desc (package-desc-version available-desc))))
            (when
             (and available-version (version-list-< installed-version available-version))
             (push (list pkg installed-desc available-desc) upgrades))))
         (nreverse upgrades)))
    (error
     (core-message-warning "Package update check failed: %s" (error-message-string err))
     nil))))

(defun
 pkg-system-ui-show-upgrades
 ()
 "Show only installed packages that have available upgrades.
Refreshes package contents and displays a list of packages with available updates,
showing current version -> new version for each package."
 (interactive)
 (core-message-package "Checking for package updates (manual check)...")
 (core-message-debug "Configured repositories: %s" (mapcar #'car package-archives))
 (let ((upgrades (pkg-system--ui-safe-refresh-and-check core-package-refresh-timeout)))
   (if
    upgrades
    (progn
     (core-message-success
      "Package refresh completed successfully - contacted %d repositories"
      (length package-archives))
     (core-message-package "Found %d packages with updates available:" (length upgrades))
     (dolist
      (pkg upgrades)
      (let ((pkg-name (car pkg))
            (current-desc (cadr pkg))
            (new-desc (caddr pkg)))
        (core-message-package
         "  %s: %s → %s"
         pkg-name
         (package-desc-version current-desc)
         (package-desc-version new-desc))))
     (core-message-package "Run M-x package-list-packages, then 'U' and 'x' to install updates"))
    (progn
     (core-message-success
      "Package refresh completed successfully - contacted %d repositories"
      (length package-archives))
     (core-message-package "No package updates available - all packages are up to date.")))))

(provide 'pkg-system-ui)
;;; pkg-system-ui.el ends here
