;;; package-repositories.el --- Repository Configuration and Security -*- lexical-binding: t -*-
;;; Commentary:
;;      Package repository setup, archive priorities, and security policies.
;;      Centralizes trust policies, signature verification, and repository management.

(require 'core-constants)
(require 'core-utils)
(require 'core-logging)
(require 'package-network)

(core-utils-with-load-timing
 "package-repositories.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Package Repository Configuration
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (require 'cl-lib) (require 'package)

 ;; Enable package repositories - MELPA only for latest packages with fixes
 (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

 ;; Set package archive priorities (higher number = higher priority)
 ;;
 ;; Search order for packages (Emacs tries highest priority first):
 ;; 1. GNU ELPA (20)     - Official GNU packages with FSF copyright assignment (https://elpa.gnu.org/)
 ;; 2. NonGNU ELPA (15)  - Semi-official packages without copyright assignment (https://elpa.nongnu.org/)
 ;; 3. MELPA (10)        - Latest development versions from community (https://melpa.org/)
 ;;
 ;; This ensures we get the latest fixes (like doom-themes issue #793) while maintaining security
 (setq
  package-archive-priorities
  `(("gnu" . 20) ; Highest priority for official packages
    ("nongnu" . 15) ; Semi-official packages
    ("melpa" . ,core-melpa-priority)))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Security Configuration
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Secure keyring management - pin keyring updates to GNU ELPA for security
 (add-to-list 'package-pinned-packages '("gnu-elpa-keyring-update" . "gnu"))

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
        (core-message-success "GNU ELPA keyring updated for secure package verification"))
     (error
      (core-message-warning "Failed to install keyring update: %s" (error-message-string err))))))

 (provide 'package-repositories))
