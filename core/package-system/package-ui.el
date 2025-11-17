;;; package-ui.el --- Interactive Package Management UI -*- lexical-binding: t -*-
;;; Commentary:
;;      User-facing interfaces for package browsing, searching, and management.
;;      Provides interactive commands for discovering and managing packages.

;;; Code:
(require 'core-constants)
(require 'core-logging)
(require 'core-user-interaction-utils)

;; Declare external functions to suppress byte-compiler warnings
(declare-function package-upgrade "package" (pkg &optional dont-select))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 show-installed-packages ()
 "Show installed packages with clear status labels and update information.
Packages are labeled as either \='Installed (by User)\=' or \='Dependency\='.
Shows available version and indicates if updates are available."
 (interactive)
 (let ((buf (get-buffer-create "*Installed Packages*"))
       (packages-with-updates '()))

   ;; Ensure package archive contents are loaded
   (unless package-archive-contents (package-refresh-contents))
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
        (show-installed-packages))))
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
 search-packages ()
 "Search for packages by name or keyword in available repositories.

Prompts for a search term and displays matching packages from all configured
package repositories. Shows package descriptions and installation status.
Useful for discovering new packages or finding alternatives."
 (interactive)
 (let ((search-term (core-user-read-string "Search packages: ")))
   (when
    (and search-term (not (string-empty-p search-term)))
    ;; Use package-show-package-list with keywords parameter to avoid async refresh issues
    (package-show-package-list t (list search-term)))))
(provide 'package-ui)
;;; package-ui.el ends here
