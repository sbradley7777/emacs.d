;;; bootstrap.el --- Use-Package Bootstrap and Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Network-aware use-package installation and fallback handling.
;;      Global use-package settings and error recovery for offline scenarios.

(require 'core-constants)
(require 'package-system/network)
(require 'core-utils)

(core-utils-with-load-timing
 "bootstrap.el"

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
     (declare (ignorable args))
     `(message "Skipping %s configuration (use-package unavailable)" ',name))))

 ;; Make this module available for loading with (require 'package-system/bootstrap)
 (provide 'package-system/bootstrap))
