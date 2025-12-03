;;; package-installation.el --- Robust Package Installation Utilities -*- lexical-binding: t -*-
;;; Commentary:
;;      Low-level package installation primitives with comprehensive error handling.
;;      Provides safe installation with retry logic and detailed reporting.

;;; Code:
(require 'core-constants)
(require 'core-logging)
(require 'core-utils)
(require 'pkg-system-repositories)
(require 'pkg-system-refresh)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 pkg-system-ensure-keyring ()
 "Ensure GNU ELPA keyring is available before installing other packages.
This maintains security with signature verification.
Should be called during initialization after package system is configured."
 (unless
  (package-installed-p 'gnu-elpa-keyring-update)
  (if
   noninteractive (logging-batch-skip "keyring update check")
   (when
    (pkg-system-responsive-p) (pkg-system-refresh-with-timeout)
    (condition-case err
        (progn
         (package-install 'gnu-elpa-keyring-update)
         (logging-success "GNU ELPA keyring updated for secure package verification"))
      (error
       (logging-warning "Failed to install keyring update: %s" (error-message-string err))))))))

(defun
 pkg-system--installation-install-safely
 (package-list)
 "Install packages from PACKAGE-LIST with comprehensive error handling."
 (let ((failed-packages '())
       (installed-count 0)
       (skipped-count 0))

   (logging-package "Installing %d packages..." (length package-list))

   (dolist
    (package package-list)
    (cond
     ;; Already installed
     ((package-installed-p package)
      (core-increment-counter skipped-count)
      (logging-success "Already installed: %s" package))

     ;; Install with error handling
     (t
      (condition-case err
          (progn
           (package-install package)
           (core-increment-counter installed-count)
           (logging-success "Installed: %s" package))
        (error
         (push package failed-packages)
         (logging-error "Failed to install %s: %s" package (error-message-string err)))))))

   ;; Installation summary
   (let ((lines nil)
         (format-str "%-22s"))
     (push (format (concat "ℹ️  " format-str " %d") "Installed" installed-count) lines)
     (push (format (concat "ℹ️  " format-str " %d") "Already present" skipped-count) lines)
     (when
      failed-packages
      (push (format (concat "❌  " format-str " %d") "Failed" (length failed-packages)) lines)
      (dolist (pkg failed-packages) (push (format "  - %s" pkg) lines))
      (push "ℹ️  Consider running (package-refresh-contents) and retrying" lines))
     (logging-diagnostic "Package Installation Summary" (nreverse lines)))

   ;; Return list of failed packages for further handling
   failed-packages))

(defun
 pkg-system-install-with-retry (package-list &optional max-retries)
 "Install packages with automatic retry on network failures.
PACKAGE-LIST is the list of packages to install.
MAX-RETRIES is the maximum number of retry attempts (default: 2)."
 (let ((max-retries (or max-retries 2))
       (failed-packages (pkg-system--installation-install-safely package-list)))
   (when
    (and failed-packages (> max-retries 0))
    (logging-loading "Retrying failed packages after network refresh...")
    (package-refresh-contents)
    (pkg-system-install-with-retry failed-packages (1- max-retries)))))
(provide 'pkg-system-installation)
;;; pkg-system-installation.el ends here
