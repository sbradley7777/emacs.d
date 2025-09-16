;;; tramp-config.el --- Enhanced TRAMP remote file access configuration -*- lexical-binding: t; -*-

;; Author: Emacs Configuration
;; Keywords: tramp, remote, files
;; Package-Requires: ((emacs "24.1"))

;;; Commentary:

;; TRAMP (Transparent Remote Access, Multiple Protocol) configuration for
;; seamless remote file editing. This module provides:
;;
;; - SSH-based remote file access
;; - Python development support with virtual environments
;; - Performance optimizations for remote connections
;; - Minimal logging by default (can be enabled in local.el)
;; - Proper cache management

;;; Code:

(require 'core-utils)
(require 'tramp-utils)

(with-load-timing
 "TRAMP remote file access with Python support"

 ;; Load TRAMP
 (require 'tramp)

 ;; Default connection method and shell
 (setq tramp-default-method "ssh")
 (setq tramp-default-remote-shell "/bin/bash")

 ;; Setup Python-specific paths and environment
 (tramp-setup-python-paths)
 (tramp-setup-python-environment)

 ;; Minimal logging (errors only) - can be overridden in local.el
 (setq tramp-verbose 1)

 ;; Cache and auto-save locations
 (setq tramp-persistency-file-name (expand-file-name "tramp-cache" user-emacs-directory))
 (setq tramp-auto-save-directory (expand-file-name "tramp-autosave" user-emacs-directory))

 ;; Performance optimizations
 (setq tramp-use-ssh-controlmaster-options nil)
 (setq tramp-completion-reread-directory-timeout nil))

(provide 'tramp-config)

;;; tramp-config.el ends here
