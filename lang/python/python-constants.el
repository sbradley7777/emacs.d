;;; python-constants.el --- Python Configuration Constants -*- lexical-binding: t -*-
;;; Commentary:
;;      Centralized constants for Python development configuration.
;;      This file contains paths, settings, and other constants used
;;      across multiple Python-related configuration files.
;;; Code:
(require 'core-utils)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Shared project state variables (auto-detected project tracking)
(defvar pyvenv-project-root nil "Auto-detected project root - set once and remembered.")
(defvar pyvenv-project-name nil "Auto-detected project name for modeline display.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Python interpreter constants
(defconst
 python-default-interpreter
 (or (executable-find "python3") (executable-find "python") "python3")
 "Default Python interpreter executable path.")

;; Virtual environment constants
(defconst
 pyvenv-project-markers
 '(".git" "pyproject.toml" "requirements.txt")
 "Files/directories that indicate a Python project root.")
(defconst
 pyvenv-venv-directory-name "venv" "Default virtual environment directory name to search for.")
(provide 'python-constants)
;;; python-constants.el ends here
