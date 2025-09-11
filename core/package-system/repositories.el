;;; repositories.el --- Repository Configuration and Security -*- lexical-binding: t -*-
;;; Commentary:
;;      Package repository setup, archive priorities, and security policies.
;;      Centralizes trust policies, signature verification, and repository management.

(require 'core-constants)
(require 'package-system/network)
(require 'core-utils)

(with-load-timing
 "repositories.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Package Repository Configuration
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (require 'cl-lib)
 (require 'package)

 ;; Enable both MELPA repositories for maximum package availability
 (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
 (add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)

 ;; Set package archive priorities (higher number = higher priority)
 ;; Prefer stable packages, fallback to development versions
 (setq
  package-archive-priorities
  `(("melpa-stable" . ,core-melpa-stable-priority)
    ("gnu" . ,core-gnu-priority)
    ("melpa" . ,core-melpa-priority)))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Security Configuration
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Secure keyring management - pin keyring updates to GNU ELPA for security
 (add-to-list 'package-pinned-packages '("gnu-elpa-keyring-update" . "gnu"))

 ;; Pin completion framework to stable version for reliability
 (add-to-list 'package-pinned-packages '("corfu" . "melpa-stable"))

 ;; Enhanced security configuration for package verification
 (setq
  package-check-signature 'allow-unsigned ; Verify signatures when available, allow unsigned
  package-unsigned-archives '("melpa")) ; Explicitly allow unsigned packages from MELPA

 ;; Ensure GNU ELPA keyring is available before installing other packages
 ;; This maintains security with signature verification
 (unless
  (package-installed-p 'gnu-elpa-keyring-update)
  (when
   (network-responsive-p)
   (safe-package-refresh-with-timeout) ; Network-aware refresh
   (condition-case err
       (progn
        (package-install 'gnu-elpa-keyring-update)
        (message "🔐  GNU ELPA keyring updated for secure package verification"))
     (error
      (message "⚠️  Failed to install keyring update: %s" (error-message-string err))))))

 ;; Make this module available for loading with (require 'package-system/repositories)
 (provide 'package-system/repositories))
