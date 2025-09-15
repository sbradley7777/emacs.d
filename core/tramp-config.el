;;; tramp-config.el --- TRAMP remote file access configuration -*- lexical-binding: t; -*-

;; Author: Emacs Configuration
;; Keywords: tramp, remote, files
;; Package-Requires: ((emacs "24.1"))

;;; Commentary:

;; TRAMP (Transparent Remote Access, Multiple Protocol) configuration for
;; seamless remote file editing. This module provides:
;;
;; - SSH-based remote file access
;; - Performance optimizations for remote connections
;; - Minimal logging by default (can be enabled in local.el)
;; - Proper cache management

;;; Code:

(with-load-timing
 "TRAMP remote file access"
 ;; Load TRAMP
 (require 'tramp)

 ;; Default connection method
 (setq tramp-default-method "ssh")

 ;; Minimal logging (errors only) - can be overridden in local.el
 (setq tramp-verbose 1)

 ;; Cache location
 (setq tramp-persistency-file-name "~/.emacs.d/tramp")

 ;; Performance optimizations
 (setq tramp-use-ssh-controlmaster-options nil)
 (setq tramp-completion-reread-directory-timeout nil))

(provide 'tramp-config)

;;; tramp-config.el ends here
