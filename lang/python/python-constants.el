;;; python-constants.el --- Python Configuration Constants -*- lexical-binding: t -*-
;;; Commentary:
;;      Centralized constants for Python development configuration.
;;      This file contains paths, settings, and other constants used
;;      across multiple Python-related configuration files.

(require 'core-utils)

(with-load-timing
 "python-constants.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Python Development Constants
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;; LSP Server Configuration
 (defconst
  python-eglot-pylsp-path "~/.local/bin/pylsp" "Path to the pylsp (Python LSP Server) executable.")

 ;; Make this module available for loading with (require 'python-constants)
 (provide 'python-constants))
