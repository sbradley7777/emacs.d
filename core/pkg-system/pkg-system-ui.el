;;; package-ui.el --- Interactive Package Management UI -*- lexical-binding: t -*-
;;; Commentary:
;;      User-facing interfaces for package browsing, searching, and management.
;;      Provides interactive commands for discovering and managing packages.

;;; Code:
(require 'core-constants)
(require 'logging-init)
(require 'core-user-interaction-utils)
(require 'pkg-system-operations)
(require 'pkg-system-repositories)

;; Declare external functions to suppress byte-compiler warnings
(declare-function package-upgrade "package" (pkg &optional dont-select))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 pkg-system--ui-find-upgradable-packages ()
 "Find all installed packages that have available upgrades.
Returns list of (PKG-NAME INSTALLED-DESC AVAILABLE-DESC)."
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

(defun
 pkg-system--ui-format-update-count
 (count)
 "Format update count message for COUNT packages."
 (format "  %d package update%s available." count (if (> count 1) "s" "")))

(defun
 pkg-system--ui-insert-update-button (packages refresh-callback)
 "Insert update button for PACKAGES with REFRESH-CALLBACK after update.
PACKAGES can be a list of package names or upgrade info lists.
REFRESH-CALLBACK is the function to call after successful update."
 (let ((inhibit-read-only t))
   (insert-button
    "[Update All]" 'action
    (lambda
     (_)
     (when
      (yes-or-no-p
       (format "Update %d package%s? " (length packages) (if (> (length packages) 1) "s" "")))
      (dolist (pkg packages) (if (listp pkg) (package-upgrade (car pkg)) (package-upgrade pkg)))
      (let ((inhibit-message t))
        (package-initialize))
      (logging-success "Updated %d packages" (length packages))
      (sit-for 1)
      (funcall refresh-callback))))))

(defun
 pkg-system--ui-prompt-update (packages)
 "Prompt user to update PACKAGES.
PACKAGES can be a list of package names or upgrade info lists.
Uses idle timer to avoid interfering with buffer display."
 (run-with-idle-timer
  0.1 nil
  (lambda
   ()
   (when
    (yes-or-no-p
     (format "Update %d package%s? " (length packages) (if (> (length packages) 1) "s" "")))
    (dolist (pkg packages) (if (listp pkg) (package-upgrade (car pkg)) (package-upgrade pkg)))
    (let ((inhibit-message t))
      (package-initialize))
    (logging-success "Updated %d packages. Refresh the view to see changes." (length packages))))))

(defun
 pkg-system--ui-sort-by-version (entry1 entry2)
 "Sort tabulated-list entries ENTRY1 and ENTRY2 by version number.
Compares version strings from the tabulated-list entry format.
Returns t if ENTRY1 version is less than ENTRY2 version."
 (let ((ver1-str (aref (cadr entry1) 1))
       (ver2-str (aref (cadr entry2) 1)))
   (cond
    ((string-empty-p ver1-str)
     t)
    ((string-empty-p ver2-str)
     nil)
    (t
     (version-list-< (version-to-list ver1-str) (version-to-list ver2-str))))))


(defun
 pkg-system--ui-setup-tabulated-list ()
 "Set up tabulated list format for package display.
Defines 5 columns: Package, Installed, Update Available, Status, Description.
Version columns are right-aligned for better readability."
 (setq
  tabulated-list-format
  (vector
   '("Package" 40 t)
   '("Installed" 20 pkg-system--ui-sort-by-version :right-align t)
   '("Update Available" 20 pkg-system--ui-sort-by-version :right-align t)
   '("Status" 22 t)
   '("Description" 0 t)))
 (setq tabulated-list-sort-key '("Package" . nil)) (tabulated-list-init-header))

(defun
 pkg-system--ui-package-to-entry (pkg)
 "Convert package PKG to tabulated-list entry format.
PKG is a package symbol.
Returns (ID . [Package Installed UpdateAvailable Status Description]) structure."
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
           (package-version-join available-version))
          (t
           ""))))
   (list
    pkg
    (vector
     (symbol-name pkg)
     (package-version-join installed-version)
     update-str
     status
     (or summary "")))))

(defun
 pkg-system--ui-create-entries (packages)
 "Create tabulated-list entries from PACKAGES list.
PACKAGES is list of package symbols.
Returns list of entries suitable for `tabulated-list-entries'."
 (mapcar #'pkg-system--ui-package-to-entry (sort packages #'string<)))

(defun
 pkg-system-ui-show-installed ()
 "Show installed packages with clear status labels and update information.
Packages are labeled as either \='Installed (by User)\=' or \='Dependency\='.
Shows available version and indicates if updates are available."
 (interactive)
 (let* ((buf (get-buffer-create "*Installed Packages*"))
        (packages-with-updates nil))
   ;; Always refresh package archive contents to ensure accurate update information
   (when
    (pkg-system-responsive-p) (logging-package "Refreshing package archive contents...")
    (condition-case err
        (with-timeout
         (core-package-refresh-timeout
          (logging-warning "Package refresh timed out - using cached data"))
         (package-refresh-contents) (logging-success "Package archive refreshed successfully"))
      (error
       (logging-warning "Failed to refresh package contents: %s" (error-message-string err)))))
   (with-current-buffer
    buf
    (let* ((inhibit-read-only t)
           (all-packages (mapcar #'car package-alist))
           (updates (mapcar #'car (pkg-system--ui-find-upgradable-packages))))
      (setq packages-with-updates updates)
      ;; Set up tabulated-list-mode
      (tabulated-list-mode)
      (pkg-system--ui-setup-tabulated-list)
      (setq tabulated-list-entries (lambda () (pkg-system--ui-create-entries all-packages)))
      ;; Insert button and update count before printing table
      (when
       packages-with-updates
       (pkg-system--ui-insert-update-button packages-with-updates #'pkg-system-ui-show-installed)
       (insert (pkg-system--ui-format-update-count (length packages-with-updates)))
       (insert "\n\n"))
      ;; Print table with headers
      (tabulated-list-print t)
      ;; Insert separator and total at bottom
      ;; Width: 200 chars to accommodate longer package descriptions
      (goto-char (point-max))
      (insert (make-string 200 ?-))
      (insert "\n")
      (insert
       (format
        "%-40s %20d %20d %-22s %s"
        "Total"
        (length all-packages)
        (length packages-with-updates)
        "-"
        "-"))
      (goto-char (point-min))))
   (switch-to-buffer buf)
   ;; Prompt user to update packages after short delay
   (when packages-with-updates (pkg-system--ui-prompt-update packages-with-updates))))

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
        (timeout-seconds (logging-warning "Package update check timed out"))
        (package-refresh-contents))
       (pkg-system--ui-find-upgradable-packages))
    (error
     (logging-warning "Package update check failed: %s" (error-message-string err))
     nil))))

(defun
 pkg-system-ui-show-upgrades
 ()
 "Show only installed packages that have available upgrades.
Refreshes package contents and displays a list of packages with available updates."
 (interactive)
 (logging-package "Checking for package updates (manual check)...")
 (logging-debug "Configured repositories: %s" (mapcar #'car package-archives))
 (let ((upgrades (pkg-system--ui-safe-refresh-and-check core-package-refresh-timeout)))
   (if
    upgrades
    (let ((buf (get-buffer-create "*Package Updates*"))
          (package-names (mapcar #'car upgrades)))
      (logging-success
       "Package refresh completed successfully - contacted %d repositories"
       (length package-archives))
      (logging-package "Found %d packages with updates available:" (length upgrades))
      (dolist
       (pkg upgrades)
       (let ((pkg-name (car pkg))
             (current-desc (cadr pkg))
             (new-desc (caddr pkg)))
         (logging-package
          "  %s: %s → %s"
          pkg-name
          (package-desc-version current-desc)
          (package-desc-version new-desc))))
      (with-current-buffer
       buf
       (let ((inhibit-read-only t))
         ;; Set up tabulated-list-mode
         (tabulated-list-mode)
         (pkg-system--ui-setup-tabulated-list)
         (setq tabulated-list-entries (lambda () (pkg-system--ui-create-entries package-names)))
         ;; Insert button and update count before printing table
         (pkg-system--ui-insert-update-button upgrades #'pkg-system-ui-show-upgrades)
         (insert (pkg-system--ui-format-update-count (length upgrades)))
         (insert "\n\n")
         ;; Print table with headers
         (tabulated-list-print t)
         ;; Insert separator and total at bottom
         ;; Width: 200 chars to accommodate longer package descriptions
         (goto-char (point-max))
         (insert (make-string 200 ?-))
         (insert "\n")
         (insert
          (format
           "%-40s %20d %20d %-22s %s"
           "Total"
           (length package-names)
           (length package-names)
           "-"
           "-"))
         (goto-char (point-min))))
      (switch-to-buffer buf)
      ;; Prompt user to update packages after displaying
      (pkg-system--ui-prompt-update upgrades))
    (logging-success
     "Package refresh completed successfully - contacted %d repositories"
     (length package-archives))
    (logging-package "No package updates available - all packages are up to date."))))

(provide 'pkg-system-ui)
;;; pkg-system-ui.el ends here
