;;; python-utils.el --- Python Project Detection Utilities -*- lexical-binding: t -*-
;;; Commentary:
;;      Centralized utility functions for Python project detection.
;;      Uses Emacs built-in functions for finding project roots, extracting
;;      project names, and locating virtual environments. TRAMP-compatible.

;;; Code:
(require 'core-utils)
(require 'core-logging)
(require 'python-constants)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Python Project Detection Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 python-utils-find-project-root (&optional directory)
 "Find Python project root using built-in locate-dominating-file.
Returns the project root path, or nil if not in a Python project.
Uses markers from pyvenv-project-markers to identify project root.
DIRECTORY defaults to default-directory if not provided."
 (let ((current-dir (or directory default-directory)))
   (cl-some (lambda (marker) (locate-dominating-file current-dir marker)) pyvenv-project-markers)))

(defun
 python-utils-extract-project-name (project-root)
 "Extract project name from PROJECT-ROOT path.
Uses built-in file name functions to get the directory name.
Returns project name as a string, or nil if PROJECT-ROOT is nil."
 (when project-root (file-name-nondirectory (directory-file-name project-root))))

(defun
 python-utils-find-venv-path (&optional directory)
 "Find virtual environment path by locating project root and venv directory.
Returns the venv path if found, nil otherwise.
DIRECTORY defaults to default-directory if not provided.
TRAMP-compatible - works with both local and remote files."
 (when-let ((project-root (python-utils-find-project-root directory)))
   (let ((venv-path (expand-file-name pyvenv-venv-directory-name project-root)))
     (when (file-directory-p venv-path) venv-path))))

(core-message-config "Python utility functions loaded")
(provide 'python-utils)
;;; python-utils.el ends here
