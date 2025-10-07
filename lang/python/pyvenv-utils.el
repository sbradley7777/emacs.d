;;; pyvenv-utils.el --- Utility functions for Python virtual environment management -*- lexical-binding: t -*-
;;; Commentary:
;;      Shared utility functions used by both pyvenv-config.el and
;;      pyvenv-remote.el for Python virtual environment management.

(require 'python-constants)

(core-utils-with-load-timing
 "pyvenv-utils.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Shared Utility Functions
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
    (core-message-loading "Searching for Python venv starting from: %s" current-dir)
    ;; Look for project markers first to establish project root
    (let ((project-root
           (cl-some
            (lambda (marker) (locate-dominating-file current-dir marker)) pyvenv-project-markers)))
      (when
       project-root
       (let ((venv-path (expand-file-name pyvenv-venv-directory-name project-root)))
         (if
          (file-directory-p venv-path)
          (progn (core-message-success "Found Python venv at: %s" venv-path) venv-path)
          (core-message-warning "No venv directory found at: %s" venv-path)
          nil))))))

 (provide 'pyvenv-utils))

;;; pyvenv-utils.el ends here
