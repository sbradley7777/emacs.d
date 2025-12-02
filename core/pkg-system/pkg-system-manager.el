;;; package-manager.el --- Package System Orchestration -*- lexical-binding: t -*-
;;; Commentary:
;;      Coordinates package system initialization and module loading.
;;      Central entry point for the modular package management system.

;;; Code:
;; Declare external functions to suppress byte-compiler warnings
(declare-function package-activate-all "package" ())
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load Package Management Modules in Dependency Order
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Layer 1: Foundation - Pure utilities with no package.el dependencies
(require 'pkg-system-metadata) ; Metadata persistence (no package.el calls)
(require 'pkg-system-cache) ; Package state caching (no package.el calls at load)
(require 'pkg-system-network-utils) ; Pure network testing utilities
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package System Initialization
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; IMPORTANT: Initialize package.el BEFORE loading modules that use package functions
;; (package-repositories.el calls package-installed-p at line 159)
;; (package-bootstrap.el calls package-installed-p at line 16)
(unless package--initialized (package-initialize))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load Remaining Package Management Modules
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Layer 2: Repository & Refresh - Repository management and refresh operations
(require 'pkg-system-repositories) ; Repository configuration, security, health checking
(require 'pkg-system-refresh) ; Centralized package refresh logic with timeout protection

;; Layer 3: Operations - High-level package operations
(require 'pkg-system-operations) ; High-level package operations and orchestration
(require 'pkg-system-bootstrap) ; Use-package installation and configuration
(require 'pkg-system-installation) ; Robust package installation utilities

;; Layer 4: User-Facing - Interactive commands and diagnostics
(require 'pkg-system-maintenance) ; Package upgrade and cleanup utilities
(require 'pkg-system-ui) ; Interactive package management interfaces
(require 'pkg-system-diagnostics) ; Diagnostic and reporting commands

;; Smart package state management with caching
(pkg-system-operations-manage-state)

;; Ensure GNU ELPA keyring is available for secure package verification
(pkg-system-ensure-keyring)

(provide 'pkg-system-manager)
;;; pkg-system-manager.el ends here
