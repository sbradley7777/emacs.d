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
 ;; Install use-package if not already present
 (unless
  (package-installed-p 'use-package)
  (message "📦  Installing use-package...")
  (package-install 'use-package))

 ;; Configure use-package for optimal package management
 (require 'use-package)

 ;; Global use-package configuration
 (setq
  use-package-always-ensure t ; Always ensure packages are installed
  use-package-verbose t ; Show loading messages for debugging
  use-package-compute-statistics t ; Enable statistics collection
  use-package-minimum-reported-time core-use-package-minimum-reported-time) ; Report slow-loading packages

 ;; Make this module available for loading with (require 'package-system/bootstrap)
 (provide 'package-system/bootstrap))
