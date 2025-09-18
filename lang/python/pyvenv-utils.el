;;; pyvenv-utils.el --- Utility functions for Python virtual environment management -*- lexical-binding: t -*-
;;; Commentary:
;;      Shared utility functions used by both pyvenv-config.el and
;;      pyvenv-remote.el for Python virtual environment management.

(require 'core-utils)
(require 'python-constants)

(core-utils-with-load-timing
 "pyvenv-utils.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Shared Utility Functions
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;; Utility function for path normalization (TRAMP-ready)
 (defun
  pyvenv-normalize-path (path) "Normalize path for comparison. Handles both local and TRAMP paths."
  (if
   (file-remote-p path)
   (file-local-name path) ; Strip TRAMP prefix for comparison
   (expand-file-name path))) ; Expand local paths

 ;; Function to detect Python version from virtual environment
 (defun
  pyvenv-get-python-version (venv-path) "Get Python version from virtual environment."
  (when
   venv-path
   (let ((python-executable (expand-file-name "bin/python" venv-path)))
     (when
      (file-executable-p python-executable)
      (with-temp-buffer
       (call-process python-executable nil t nil "--version")
       (goto-char (point-min))
       (when (re-search-forward "Python \\([0-9]+\\.[0-9]+\\)" nil t) (match-string 1)))))))

 ;; Function to find virtual environment in current directory or parents
 (defun
  pyvenv-find-venv
  (&optional start-dir)
  "Find virtual environment by searching current directory and parents."
  (let ((current-dir (or start-dir default-directory)))
    (message "🔍 Searching for Python venv starting from: %s" current-dir)
    ;; Look for project markers first to establish project root
    (let ((project-root
           (cl-some
            (lambda (marker) (locate-dominating-file current-dir marker)) pyvenv-project-markers)))
      (when
       project-root
       (let ((venv-path (expand-file-name pyvenv-venv-directory-name project-root)))
         (if
          (file-directory-p venv-path)
          (progn (message "✅ Found Python venv at: %s" venv-path) venv-path)
          (message "❌ No venv directory found at: %s" venv-path)
          nil))))))

 ;; Function to update modeline based on current file location
 (defun
  pyvenv-update-modeline () "Update modeline based on whether current file is in detected project."
  (let ((is-in-project
         (and
          pyvenv-project-root
          (string-prefix-p
           (pyvenv-normalize-path pyvenv-project-root)
           (pyvenv-normalize-path default-directory)))))
    (setq-local pyvenv-current-project-name (if is-in-project pyvenv-project-name "inactive"))
    (setq-local
     pyvenv-current-version (if is-in-project (default-value 'pyvenv-current-version) nil))
    (force-mode-line-update)))

 ;; Debug function to check modeline variables (shared utility)
 (defun
  pyvenv-debug-modeline
  ()
  "Debug function to check modeline variables in current buffer."
  (interactive)
  (message "=== DEBUG PYTHON MODELINE ===")
  (message "Buffer: %s | File: %s" (buffer-name) (or buffer-file-name "NO FILE"))
  (message "Directory: %s" default-directory)
  (message "Remote: %s" (if (file-remote-p default-directory) "YES" "NO"))
  (message
   "Project name: %s (local: %s)"
   pyvenv-current-project-name
   (local-variable-p 'pyvenv-current-project-name))
  (message
   "Python version: %s (local: %s)"
   pyvenv-current-version
   (local-variable-p 'pyvenv-current-version))
  (message "Detected project root: %s | name: %s" pyvenv-project-root pyvenv-project-name)
  (message "=============================="))

 (provide 'pyvenv-utils))

;;; pyvenv-utils.el ends here
