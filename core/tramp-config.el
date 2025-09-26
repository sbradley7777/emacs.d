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

(require 'core-constants)
(require 'core-utils)
(require 'tramp-utils)

;; Load TRAMP
(require 'tramp)

;; Default connection method and shell
(setq tramp-default-method "ssh")
(setq tramp-default-remote-shell "/bin/bash")

;; Silent operation by default - this prevents the connection buffer from appearing.
;; Can be overridden in local.el for debugging.
(setq tramp-verbose 0)

;; Cache and auto-save locations
(setq tramp-persistency-file-name (expand-file-name "tramp" emacs-local-dir))
(setq tramp-auto-save-directory (expand-file-name "tramp-autosave" emacs-local-dir))

;; Performance optimizations
(setq tramp-use-ssh-controlmaster-options nil)
(setq tramp-completion-reread-directory-timeout nil)

(provide 'tramp-config)

;;; tramp-config.el ends here
