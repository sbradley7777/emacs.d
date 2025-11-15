;;; package-manager.el --- Package System Orchestration -*- lexical-binding: t -*-
;;; Commentary:
;;      Coordinates package system initialization and module loading.
;;      Central entry point for the modular package management system.

;;; Code:
;; Declare external functions to suppress byte-compiler warnings
(declare-function package-activate-all "package" ())

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load Package Management Modules in Order
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load foundational modules first
(require 'package-cache) ; Package state caching system
(require 'package-network) ; Network-aware package operations
(require 'package-repositories) ; Repository configuration and security
(require 'package-bootstrap) ; Use-package installation and configuration
(require 'package-installation) ; Robust package installation utilities
(require 'package-maintenance) ; Package upgrade and cleanup utilities
(require 'package-ui) ; Interactive package management interfaces

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package System Initialization
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package initialization - check if already initialized to prevent duplicate calls
(unless package--initialized (package-initialize))

;; Smart package state management with caching
(smart-package-state-management)
(provide 'package-manager)
;;; package-manager.el ends here
