;;; core-package-manager.el --- Package System Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Package manager setup, repository configuration, and use-package initialization.
;;      This file establishes the foundation for package management.

(message "Loading core-package-manager.el...")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package Repository Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'cl-lib)
(require 'package)

;; Enable both MELPA repositories for maximum package availability
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)

;; Set package archive priorities (higher number = higher priority)
;; Prefer stable packages, fallback to development versions
(setq package-archive-priorities
      '(("melpa-stable" . 20)
        ("gnu" . 15)
        ("melpa" . 10)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package System Initialization
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package initialization - check if already initialized to prevent duplicate calls
(require 'package)
(unless package--initialized
  (package-initialize))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Security Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Secure keyring management - pin keyring updates to GNU ELPA for security
(add-to-list 'package-pinned-packages '("gnu-elpa-keyring-update" . "gnu"))

;; Ensure GNU ELPA keyring is available before installing other packages
;; This maintains security with signature verification
(unless (package-installed-p 'gnu-elpa-keyring-update)
  (package-refresh-contents)                               ; Refresh package contents to get latest keyring info
  (package-install 'gnu-elpa-keyring-update)               ; Install keyring update package from GNU ELPA
  (message "GNU ELPA keyring updated for secure package verification"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package Content Management
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; If there are no archived package contents, refresh them
(when (not package-archive-contents)
  (package-refresh-contents))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Use-Package Bootstrap and Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Install use-package if not already present
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; Configure use-package for optimal package management
(eval-when-compile
  (require 'use-package))

;; Global use-package configuration
(setq use-package-always-ensure t          ; Always ensure packages are installed
      use-package-verbose t                 ; Show loading messages for debugging
      use-package-compute-statistics t      ; Enable statistics collection
      use-package-minimum-reported-time 0.1) ; Report slow-loading packages

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package Management Utilities
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun package-upgrade-all ()
  "Upgrade all installed packages to their latest versions."
  (interactive)
  (package-refresh-contents)
  (let ((upgrades (cl-remove-if-not #'package-installed-p package-alist)))
    (if upgrades
        (progn
          (mapc #'package-install upgrades)
          (message "Upgraded %d packages" (length upgrades)))
      (message "All packages are up to date"))))

(defun package-cleanup-unused ()
  "Remove unused package dependencies."
  (interactive)
  (package-autoremove)
  (message "Cleaned up unused packages"))

;; Make this module available for loading with (require 'core-package-manager)
(provide 'core-package-manager)
(message "core-package-manager.el loaded successfully.")
