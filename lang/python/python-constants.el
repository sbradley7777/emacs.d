;;; python-constants.el --- Python Configuration Constants -*- lexical-binding: t -*-
;;; Commentary:
;;      Centralized constants for Python development configuration.
;;      This file contains paths, settings, and other constants used
;;      across multiple Python-related configuration files.
(require 'core-utils)
(core-utils-with-load-timing
 "python-constants.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Python Interpreter Constants
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defconst
  python-default-interpreter
  (or (executable-find "python3") (executable-find "python") "python3")
  "Default Python interpreter executable path.")

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Virtual Environment Constants
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Project markers for virtual environment detection
 (defconst
  pyvenv-project-markers
  '(".git" "pyproject.toml" "requirements.txt")
  "Files/directories that indicate a Python project root.")
 (defconst
  pyvenv-venv-directory-name "venv" "Default virtual environment directory name to search for.")

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Shared Project State Variables
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Auto-detected project tracking (shared between local and remote)
 (defvar pyvenv-project-root nil "Auto-detected project root - set once and remembered.")
 (defvar pyvenv-project-name nil "Auto-detected project name for modeline display."))
(provide 'python-constants)
