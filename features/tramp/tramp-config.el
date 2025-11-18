;;; tramp-config.el --- Enhanced TRAMP remote file access configuration -*- lexical-binding: t; -*-
;; Author: Emacs Configuration
;; Keywords: tramp, remote, files
;; Package-Requires: ((emacs "24.1"))

;;; Commentary:

;; TRAMP (Transparent Remote Access, Multiple Protocol) configuration for
;; seamless remote file editing. This module provides:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; - SSH-based remote file access
;; - Python development support with virtual environments
;; - Performance optimizations for remote connections
;; - Minimal logging by default (can be enabled in local.el)
;; - Proper cache management

;;; Code:
(require 'core-constants)
(require 'core-utils)
(require 'features-constants)
(require 'tramp-constants)
(require 'tramp-utils)
(require 'tramp)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq tramp-default-method "ssh")
(setq tramp-default-remote-shell tramp-default-shell)
(setq tramp-persistency-file-name features-tramp-cache-file)
(setq tramp-auto-save-directory features-tramp-autosave-dir)
(core-utils-ensure-directory features-tramp-autosave-dir)
(dolist (path tramp-user-paths) (add-to-list 'tramp-remote-path path))
(add-to-list 'tramp-remote-path 'tramp-own-remote-path)
(provide 'tramp-config)
;;; tramp-config.el ends here
