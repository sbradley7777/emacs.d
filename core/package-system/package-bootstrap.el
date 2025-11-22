;;; package-bootstrap.el --- Use-Package Bootstrap and Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Network-aware use-package installation and fallback handling.
;;      Global use-package settings and error recovery for offline scenarios.

;;; Code:
(require 'core-constants)
(require 'core-logging)
(require 'package-network)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Use-Package Bootstrap and Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Install use-package if not already present
(unless
 (package-installed-p 'use-package)
 (if
  noninteractive
  (progn
   (core-message-error "use-package not installed - cannot run in batch mode")
   (core-message-error "First-time setup: Run Emacs interactively to install use-package")
   (error "Batch mode requires use-package to be installed first"))
  (core-message-package "Installing use-package...")
  (package-install 'use-package)
  (core-message-success "use-package installed successfully")))

;; Configure use-package for optimal package management
(require 'use-package)
(core-message-debug "use-package loaded and ready")

;; Global use-package configuration
(setq
 use-package-always-ensure
 (not noninteractive) ; Auto-install in interactive mode, skip in batch mode
 use-package-verbose
 t ; Show loading messages for debugging
 use-package-compute-statistics
 t ; Enable statistics collection
 use-package-minimum-reported-time
 core-use-package-minimum-reported-time) ; Report slow-loading packages

(core-message-debug
 "use-package settings: always-ensure=%s, verbose=%s, min-time=%.2fs"
 use-package-always-ensure
 use-package-verbose
 use-package-minimum-reported-time)
(provide 'package-bootstrap)
;;; package-bootstrap.el ends here
