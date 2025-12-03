;;; pyvenv-utils.el --- Utility functions for Python virtual environment management -*- lexical-binding: t -*-
;;; Commentary:
;;      Shared utility functions used by both pyvenv-config.el and
;;      pyvenv-remote.el for Python virtual environment management.

;;; Code:
(require 'core-utils)
(require 'core-logging)
(require 'python-constants)
(require 'python-utils)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 pyvenv--normalize-path (path)
 "Normalize path for comparison.  Handles both local and TRAMP paths.
PATH is the file path to normalize."
 (if (core-is-remote-file path) (file-local-name path) (expand-file-name path)))

(defun
 pyvenv-get-version-from-executable (python-executable)
 "Get Python version from PYTHON-EXECUTABLE.
Uses `process-file' for TRAMP compatibility - works for both local and remote files."
 (when
  (and python-executable (file-executable-p python-executable))
  (with-temp-buffer
   (core-message-debug "Python version check: %s" (abbreviate-file-name python-executable))
   ;; For process-file to work with TRAMP paths, we need to:
   ;; 1. Set default-directory to match the remote connection
   ;; 2. Use the local filename part (without TRAMP prefix) as the program
   (let* ((default-directory (file-name-directory python-executable))
          (program (file-local-name python-executable)))
     (process-file program nil t nil "--version")
     (let ((output (string-trim (buffer-string))))
       (goto-char (point-min))
       (if
        (re-search-forward "Python \\([0-9]+\\.[0-9]+\\(?:\\.[0-9]+\\)?\\)" nil t)
        (let ((version (match-string 1)))
          (core-message-debug "Python version: %s" version)
          version)
        (core-message-debug "Failed to parse version from: %s" output) nil))))))

(defun
 pyvenv-get-python-version (venv-path)
 "Get Python version from virtual environment.
VENV-PATH is the path to the virtual environment directory."
 (when
  venv-path
  (let ((python-executable (expand-file-name python-pyvenv-python-executable-path venv-path)))
    (pyvenv-get-version-from-executable python-executable))))

(defun
 pyvenv-find-venv (&optional start-dir)
 "Find virtual environment by searching current directory and parents.
START-DIR is the starting directory for the search (defaults to current directory)."
 (let ((current-dir (or start-dir default-directory)))
   (core-message-loading
    "Searching for Python venv starting from: %s" (abbreviate-file-name current-dir))
   (let ((venv-path (python-utils-find-venv-path current-dir)))
     (if
      venv-path
      (progn
       (core-message-success "Found Python venv at: %s" (abbreviate-file-name venv-path))
       venv-path)
      (let ((project-root (python-utils-find-project-root current-dir)))
        (when
         project-root
         (core-message-warning
          "No venv directory found at: %s"
          (abbreviate-file-name
           (expand-file-name python-pyvenv-venv-directory-name project-root)))))
      nil))))

(defun
 pyvenv-update-shell-interpreter
 ()
 "Update python-shell-interpreter when virtual environment change for modeline display."
 (if
  (and (boundp 'pyvenv-virtual-env) pyvenv-virtual-env)
  (let ((venv-python (expand-file-name python-pyvenv-python-executable-path pyvenv-virtual-env)))
    (if
     (core-is-remote-file venv-python)
     ;; For remote files, use the local path part (without TRAMP prefix)
     ;; doom-modeline will execute this in the context of default-directory,
     ;; which is a TRAMP path, so the execution will happen on the remote host
     (let ((local-python-path (file-local-name venv-python)))
       (core-message-debug
        "Setting python-shell-interpreter to '%s' for remote venv" local-python-path)
       (setq-local python-shell-interpreter local-python-path))
     ;; For local files, set to the actual executable path
     (when (file-executable-p venv-python) (setq python-shell-interpreter venv-python))))
  (setq python-shell-interpreter python-default-interpreter)))
(provide 'pyvenv-utils)
;;; pyvenv-utils.el ends here
