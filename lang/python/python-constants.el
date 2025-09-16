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

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Virtual Environment Constants
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;; Project markers for virtual environment detection
 (defconst
  pyvenv-project-markers
  '(".git" "pyproject.toml" "requirements.txt")
  "Files/directories that indicate a Python project root.")

 (defconst
  pyvenv-venv-directory-name "venv" "Default virtual environment directory name to search for.")

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Shared Project State Variables
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;; Auto-detected project tracking (shared between local and remote)
 (defvar
  config-python-detected-project-root nil "Auto-detected project root - set once and remembered.")

 (defvar
  config-python-detected-project-name nil "Auto-detected project name for modeline display.")

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Shared Modeline Variables
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;; Runtime variables for modeline display (buffer-local)
 (defvar config-python-project-name "inactive" "Current project status for modeline.")
 (make-variable-buffer-local 'config-python-project-name)
 (setq-default config-python-project-name "inactive")

 (defvar config-python-version nil "Python version of the detected virtual environment.")
 (make-variable-buffer-local 'config-python-version)
 (setq-default config-python-version nil)

 ;; Make this module available for loading with (require 'python-constants)
 (provide 'python-constants))
