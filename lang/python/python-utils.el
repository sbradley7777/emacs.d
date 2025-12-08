;;; python-utils.el --- Python Project Detection Utilities -*- lexical-binding: t -*-
;;; Commentary:
;;      Centralized utility functions for Python project detection.
;;      Provides functions for finding project roots, extracting project names,
;;      and locating virtual environments.  TRAMP-compatible.

;;; Code:
(require 'core-utils)
(require 'logging-init)
(require 'python-constants)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 python-utils-find-project-root (&optional directory)
 "Find Python project root using file markers.
Returns the project root path, or nil if not in a Python project.
Uses markers from `python-pyvenv-project-markers' to identify project root.
DIRECTORY defaults to `default-directory' if not provided."
 (core-find-dominating-directory-by-markers python-pyvenv-project-markers directory))

(defun
 python-utils-find-venv-path (&optional directory)
 "Find virtual environment path by locating project root and venv directory.
Returns the venv path if found, nil otherwise.
DIRECTORY defaults to `default-directory' if not provided.
TRAMP-compatible - works with both local and remote files."
 (when-let ((project-root (python-utils-find-project-root directory)))
   (let ((venv-path (expand-file-name python-pyvenv-venv-directory-name project-root)))
     (when (file-directory-p venv-path) venv-path))))

(logging-config "Python utility functions loaded")
(provide 'python-utils)
;;; python-utils.el ends here
