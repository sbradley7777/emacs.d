;;; package-bootstrap.el --- Use-Package Bootstrap and Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Network-aware use-package installation and fallback handling.
;;      Global use-package settings and error recovery for offline scenarios.

;;; Code:
(require 'core-constants)
(require 'core-logging)
(require 'pkg-system-operations)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Use-Package Bootstrap and Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Install use-package if not already present
(unless
 (package-installed-p 'use-package)
 (if
  noninteractive
  (progn
   (logging-error "use-package not installed - cannot run in batch mode")
   (logging-error "First-time setup: Run Emacs interactively to install use-package")
   (error "Batch mode requires use-package to be installed first"))
  (logging-package "Installing use-package...")
  (package-install 'use-package)
  (logging-success "use-package installed successfully")))

;; Configure use-package for optimal package management
(require 'use-package)
(logging-debug "use-package loaded and ready")

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

(logging-debug
 "use-package settings: always-ensure=%s, verbose=%s, min-time=%.2fs"
 use-package-always-ensure
 use-package-verbose
 use-package-minimum-reported-time)
(provide 'pkg-system-bootstrap)
;;; pkg-system-bootstrap.el ends here
