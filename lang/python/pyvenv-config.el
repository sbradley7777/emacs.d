;;; pyvenv-config.el --- Auto-detect Once Python Virtual Environment Management -*- lexical-binding: t -*-
;;; Commentary:
;;      AUTO-DETECT ONCE APPROACH: Automatically detects the first Python virtual
;;      environment encountered and remembers it as THE project.  The virtual
;;      environment is activated.  The built-in pyvenv modeline indicator is disabled
;;      in favor of our custom doom-modeline segment (defined in pyvenv-modeline.el).

;;; Code:
(require 'core-utils)
(require 'logging-init)
(require 'python-constants)
(require 'python-utils)
(require 'pyvenv-utils)
(require 'lang-utils)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 pyvenv-auto-activate ()
 "Auto-detect and activate Python virtual environment for current project.

Searches for a virtual environment in the project root and activates it.
Only runs once per project - subsequent calls are ignored to avoid redundant
activation.  Searches for common venv directory names (.venv, venv, env).
Updates Python interpreter path and modeline after successful activation."
 (interactive)
 (unless
  pyvenv-project-root (logging-info "Auto-detecting Python virtual environment...")
  (let ((detected-venv (pyvenv-find-venv)))
    (if
     detected-venv
     (progn
      ;; Remember the project root to prevent re-detection
      (let ((project-dir (file-name-directory (directory-file-name detected-venv))))
        (setq
         pyvenv-project-root
         project-dir
         pyvenv-project-name
         (core-extract-directory-name project-dir)))

      ;; pyvenv-activate sets python-shell-virtualenv-path (Python mode's primary interpreter source)
      (if
       (fboundp 'pyvenv-activate)
       (progn
        (pyvenv-activate detected-venv)
        (logging-success "Activated Python venv for project: %s" pyvenv-project-name)

        ;; Log detected Python version for user feedback
        (let ((python-version (pyvenv-get-python-version detected-venv)))
          (if
           python-version
           (logging-info "Using Python %s from virtual environment" python-version)
           (logging-warning "Could not detect Python version in virtual environment"))))
       (logging-warning "Warning: pyvenv-activate function not available")))
     (logging-warning "No Python virtual environment found")))))

;; Initialize pyvenv package and enable pyvenv-mode
(if
 (fboundp 'use-package)
 (use-package
  pyvenv
  :config (pyvenv-mode 1)
  ;; Disable the built-in pyvenv modeline indicator (we use our custom doom-modeline segment instead)
  (setq pyvenv-mode-line-indicator nil))
 (when
  (require 'pyvenv nil t) (pyvenv-mode 1)
  ;; Disable the built-in pyvenv modeline indicator
  (setq pyvenv-mode-line-indicator nil)))

;; Hook into pyvenv activation/deactivation to update python-shell-interpreter for doom-modeline
;; Note: python-shell-virtualenv-path remains the primary interpreter source for Python mode
(add-hook 'pyvenv-post-activate-hooks #'pyvenv-update-shell-interpreter)
(add-hook 'pyvenv-post-deactivate-hooks #'pyvenv-update-shell-interpreter)

;; Trigger auto-detection when opening Python files (both python-mode and python-ts-mode)
(lang-add-dual-mode-hooks 'python-mode-hook 'python-ts-mode-hook #'pyvenv-auto-activate)
(provide 'pyvenv-config)
;;; pyvenv-config.el ends here
