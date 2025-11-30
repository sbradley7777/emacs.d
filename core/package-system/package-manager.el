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
(require 'package-metadata) ; Metadata persistence (no package.el calls)
(require 'package-cache) ; Package state caching (no package.el calls at load)
(require 'package-network-utils) ; Pure network testing utilities
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
;; Layer 2: Domain - Repository management (requires package.el)
(require 'package-repositories) ; Repository configuration, security, health checking

;; Layer 3: Orchestration - High-level package operations
(require 'package-operations) ; High-level package operations and orchestration
(require 'package-bootstrap) ; Use-package installation and configuration
(require 'package-installation) ; Robust package installation utilities
(require 'package-maintenance) ; Package upgrade and cleanup utilities
(require 'package-ui) ; Interactive package management interfaces

;; Smart package state management with caching
(smart-package-state-management)

;; Ensure GNU ELPA keyring is available for secure package verification
(package-repositories-ensure-keyring)

(provide 'package-manager)
;;; package-manager.el ends here
