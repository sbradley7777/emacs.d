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

 ;; Path normalization for both local and remote (TRAMP) files
 (defun
  pyvenv-normalize-path
  (path)
  "Normalize path for comparison. Handles both local and TRAMP paths."
  (if (file-remote-p path) (file-local-name path) (expand-file-name path)))

 ;; Extract Python version from virtual environment for logging
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

 ;; Search for virtual environment by walking up directory tree looking for project markers
 ;; Returns the venv path if found, nil otherwise
 (defun
  pyvenv-find-venv
  (&optional start-dir)
  "Find virtual environment by searching current directory and parents."
  (let ((current-dir (or start-dir default-directory)))
    (core-message-loading "Searching for Python venv starting from: %s" current-dir)
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

 ;; Hook function to update python-shell-interpreter for doom-modeline compatibility
 ;; pyvenv sets python-shell-virtualenv-path (Python mode's primary), but doom-modeline reads
 ;; python-shell-interpreter, so we update both on activation/deactivation
 (defun
  pyvenv-update-shell-interpreter
  ()
  "Update python-shell-interpreter when virtual environment changes for modeline display."
  (if
   (and (boundp 'pyvenv-virtual-env) pyvenv-virtual-env)
   (let ((venv-python (expand-file-name "bin/python" pyvenv-virtual-env)))
     (when (file-executable-p venv-python) (setq python-shell-interpreter venv-python)))
   (setq python-shell-interpreter python-default-interpreter)))

 (provide 'pyvenv-utils))

;;; pyvenv-utils.el ends here
