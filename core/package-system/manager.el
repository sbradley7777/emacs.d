;;; manager.el --- Package System Orchestration -*- lexical-binding: t -*-
;;; Commentary:
;;      Coordinates package system initialization and module loading.
;;      Central entry point for the modular package management system.

(require 'core-utils)

(core-utils-with-load-timing
 "manager.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Load Package Management Modules in Order
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Load foundational modules first
 (require 'package-system/cache) ; Package state caching system
 (require 'package-system/network) ; Network-aware package operations
 (require 'package-system/repositories) ; Repository configuration and security
 (require 'package-system/bootstrap) ; Use-package installation and configuration
 (require 'package-system/maintenance) ; Package upgrade and cleanup utilities

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Package System Initialization
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Package initialization - check if already initialized to prevent duplicate calls
 (unless package--initialized (package-initialize))

 ;; Smart package state management with caching
 (smart-package-state-management)

 ;; Make this module available for loading with (require 'package-system/manager)
 (provide 'package-system/manager))
