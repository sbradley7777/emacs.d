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
 ;; TRAMP Remote Development Constants
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;; Common Python installation paths on remote systems
 (defconst
  python-tramp-remote-bin-paths
  '("~/venv/bin" ; Standard venv location
    "~/.venv/bin" ; Alternative venv location
    "~/env/bin" ; Another common location
    "~/.local/bin" ; User local packages
    "~/.pyenv/shims" ; pyenv support
    "/opt/conda/bin" ; Conda installations
    "/usr/local/python/bin") ; System Python installs
  "Common Python binary paths on remote systems.")

 ;; Python-specific environment variables for remote development
 (defconst
  python-tramp-environment-vars
  '("PYTHONIOENCODING=utf-8"
    "PYTHONUNBUFFERED=1"
    "PYTHONDONTWRITEBYTECODE=1"
    "VIRTUAL_ENV_DISABLE_PROMPT=1"
    "PIP_DISABLE_PIP_VERSION_CHECK=1")
  "Python environment variables for remote TRAMP connections.")

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Shared Project State Variables
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;; Auto-detected project tracking (shared between local and remote)
 (defvar pyvenv-project-root nil "Auto-detected project root - set once and remembered.")

 (defvar pyvenv-project-name nil "Auto-detected project name for modeline display.")

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Shared Modeline Variables
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;; Runtime variables for modeline display (buffer-local)
 (defvar pyvenv-current-project-name "inactive" "Current project status for modeline.")
 (make-variable-buffer-local 'pyvenv-current-project-name)
 (setq-default pyvenv-current-project-name "inactive")

 (defvar pyvenv-current-version nil "Python version of the detected virtual environment.")
 (make-variable-buffer-local 'pyvenv-current-version)
 (setq-default pyvenv-current-version nil)

 ;; Make this module available for loading with (require 'python-constants)
 (provide 'python-constants))
