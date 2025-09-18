;;; python-constants.el --- Python Configuration Constants -*- lexical-binding: t -*-
;;; Commentary:
;;      Centralized constants for Python development configuration.
;;      This file contains paths, settings, and other constants used
;;      across multiple Python-related configuration files.

(require 'core-utils)

(defvar pyvenv-current-project-name nil "Current project status for modeline.")
(defvar pyvenv-current-version nil "Python version of the detected virtual environment.")

(make-variable-buffer-local 'pyvenv-current-project-name)
(make-variable-buffer-local 'pyvenv-current-version)

(with-load-timing
 "python-constants.el"
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Virtual Environment Constants
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Project markers for virtual environment detection
 (defconst
  pyvenv-project-markers
  '(".git" "pyproject.toml" "requirements.txt")
  "Files/directories that indicate a Python project root.")

 (defconst
  pyvenv-venv-directory-name "venv" "Default virtual environment directory name to search for.")

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Shared Project State Variables
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;; Auto-detected project tracking (shared between local and remote)
 (defvar pyvenv-project-root nil "Auto-detected project root - set once and remembered.")

 (defvar pyvenv-project-name nil "Auto-detected project name for modeline display.")

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Shared Modeline Variables
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;; Runtime variables for modeline display (buffer-local)
 (setq-default pyvenv-current-version nil)

 ;; Make this module available for loading with (require 'python-constants)
 (provide 'python-constants))
