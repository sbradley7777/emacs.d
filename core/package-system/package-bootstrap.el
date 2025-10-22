;;; package-bootstrap.el --- Use-Package Bootstrap and Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Network-aware use-package installation and fallback handling.
;;      Global use-package settings and error recovery for offline scenarios.

(require 'core-constants)
(require 'core-utils)
(require 'core-logging)
(require 'package-network)

(core-utils-with-load-timing
 "package-bootstrap.el"
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Use-Package Bootstrap and Configuration
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Install use-package if not already present
 (unless
  (package-installed-p 'use-package)
  (core-message-package "Installing use-package...")
  (package-install 'use-package)
  (core-message-success "use-package installed successfully"))

 ;; Configure use-package for optimal package management
 (require 'use-package) (core-message-debug "use-package loaded and ready")

 ;; Global use-package configuration
 (setq
  use-package-always-ensure t ; Always ensure packages are installed
  use-package-verbose t ; Show loading messages for debugging
  use-package-compute-statistics t ; Enable statistics collection
  use-package-minimum-reported-time core-use-package-minimum-reported-time) ; Report slow-loading packages

 (core-message-debug
  "use-package settings: always-ensure=%s, verbose=%s, min-time=%.2fs"
  use-package-always-ensure
  use-package-verbose
  use-package-minimum-reported-time))

(provide 'package-bootstrap)
