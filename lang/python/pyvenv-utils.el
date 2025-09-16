;;; pyvenv-utils.el --- Utility functions for Python virtual environment management -*- lexical-binding: t -*-
;;; Commentary:
;;      Shared utility functions used by both pyvenv-config.el and
;;      pyvenv-remote.el for Python virtual environment management.

(require 'core-utils)
(require 'python-constants)

(with-load-timing
 "pyvenv-utils.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Shared Utility Functions
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;; Utility function for path normalization (TRAMP-ready)
 (defun
  normalize-path-for-comparison
  (path)
  "Normalize path for comparison. Handles both local and TRAMP paths."
  (if
   (file-remote-p path)
   (file-local-name path) ; Strip TRAMP prefix for comparison
   (expand-file-name path))) ; Expand local paths

 ;; Function to detect Python version from virtual environment
 (defun
  config-get-python-version (venv-path) "Get Python version from virtual environment."
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
  find-venv-in-parents
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
  update-python-modeline () "Update modeline based on whether current file is in detected project."
  (let ((is-in-project
         (and
          config-python-detected-project-root
          (string-prefix-p
           (normalize-path-for-comparison
            config-python-detected-project-root)
           (normalize-path-for-comparison default-directory)))))
    (setq-local
     config-python-project-name (if is-in-project config-python-detected-project-name "inactive"))
    (setq-local
     config-python-version (if is-in-project (default-value 'config-python-version) nil))
    (force-mode-line-update)))

 ;; Debug function to check modeline variables (shared utility)
 (defun
  debug-python-modeline
  ()
  "Debug function to check modeline variables in current buffer."
  (interactive)
  (message "=== DEBUG PYTHON MODELINE ===")
  (message "Buffer: %s | File: %s" (buffer-name) (or buffer-file-name "NO FILE"))
  (message "Directory: %s" default-directory)
  (message "Remote: %s" (if (file-remote-p default-directory) "YES" "NO"))
  (message
   "Project name: %s (local: %s)"
   config-python-project-name
   (local-variable-p 'config-python-project-name))
  (message
   "Python version: %s (local: %s)"
   config-python-version
   (local-variable-p 'config-python-version))
  (message
   "Detected project root: %s | name: %s"
   config-python-detected-project-root
   config-python-detected-project-name)
  (message "=============================="))

 (provide 'pyvenv-utils))

;;; pyvenv-utils.el ends here
