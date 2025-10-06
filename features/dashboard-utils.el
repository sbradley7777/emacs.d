;;; dashboard-utils.el --- Dashboard Utility Functions -*- lexical-binding: t -*-
;;; Commentary:
;;      Utility functions for dashboard operations.

(require 'core-constants)
(require 'core-utils)

(core-utils-with-load-timing
 "dashboard-utils.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Dashboard Utility Functions
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;; Helper function to show only installed packages
 (defun
  dashboard-show-installed-packages
  ()
  "Show only installed packages in package list."
  (interactive)
  (package-show-package-list (mapcar 'car package-alist)))

 ;; Helper function to search for packages
 (defun
  dashboard-search-packages () "Search for packages by name or keyword." (interactive)
  (let ((search-term (read-string "Search packages: ")))
    (when
     (and search-term (not (string-empty-p search-term)))
     ;; Use package-show-package-list with keywords parameter to avoid async refresh issues
     (package-show-package-list t (list search-term))))))

(provide 'dashboard-utils)
