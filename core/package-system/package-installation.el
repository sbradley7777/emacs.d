;;; package-installation.el --- Robust Package Installation Utilities -*- lexical-binding: t -*-
;;; Commentary:
;;      Low-level package installation primitives with comprehensive error handling.
;;      Provides safe installation with retry logic and detailed reporting.
(require 'core-constants)
(require 'core-utils)
(require 'core-logging)
(core-utils-with-load-timing
 "package-installation.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Robust Package Installation
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  core-packages-install-safely
  (package-list)
  "Install packages from PACKAGE-LIST with comprehensive error handling."
  (let ((failed-packages '())
        (installed-count 0)
        (skipped-count 0))

    (core-message-package "Installing %d packages..." (length package-list))

    (dolist
     (package package-list)
     (cond
      ;; Already installed
      ((package-installed-p package)
       (core-utils-increment-counter skipped-count)
       (core-message-success "Already installed: %s" package))

      ;; Install with error handling
      (t
       (condition-case err
           (progn
            (package-install package)
            (core-utils-increment-counter installed-count)
            (core-message-success "Installed: %s" package))
         (error
          (push package failed-packages)
          (core-message-error "Failed to install %s: %s" package (error-message-string err)))))))

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
      (core-message-diagnostic "Package Installation Summary" (nreverse lines)))

    ;; Return list of failed packages for further handling
    failed-packages))

 ;; Add retry mechanism for automatic recovery from network failures
 (defun
  core-packages-install-with-retry (package-list &optional max-retries)
  "Install packages with automatic retry on network failures.
PACKAGE-LIST is the list of packages to install.
MAX-RETRIES is the maximum number of retry attempts (default: 2)."
  (let ((max-retries (or max-retries 2))
        (failed-packages (core-packages-install-safely package-list)))
    (when
     (and failed-packages (> max-retries 0))
     (core-message-loading "Retrying failed packages after network refresh...")
     (package-refresh-contents)
     (core-packages-install-with-retry failed-packages (1- max-retries))))))
(provide 'package-installation)
;;; package-installation.el ends here
