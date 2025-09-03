;;; venv.el --- Python Virtual Environment Management -*- lexical-binding: t -*-
;;; Commentary:
;;      Complete virtual environment management with pyvenv integration,
;;      auto-activation, modeline display, and project detection.

(defvar config-load-start-time (current-time))
(message "🔄  Loading venv.el...")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Virtual environment support
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Variable to hold the project name for modeline display (global variable that persists across buffers)
(defvar
 config-python-project-name nil "Name of the project containing the current virtual environment.")
(setq-default config-python-project-name nil)

;; Clear project name when deactivating virtual environment
(defun
 config-pyvenv-post-deactivate
 ()
 "Clear project name variables when deactivating virtual environment."
 (setq-default config-python-project-name nil)
 (setq config-python-project-name nil)
 (force-mode-line-update t))

;; Set project name when virtual environment is activated
(defun
 config-pyvenv-post-activate
 ()
 "Extract and set project name from virtual environment path for modeline display."
 (when
  pyvenv-virtual-env
  ;; Small delay to ensure we run after all other hooks
  (run-with-timer
   0.1 nil
   (lambda
    () "Update project name variables with extracted project name."
    (let* ((venv-parent-dir (file-name-directory (directory-file-name pyvenv-virtual-env)))
           (project-name (file-name-nondirectory (directory-file-name venv-parent-dir))))
      (setq-default config-python-project-name project-name)
      (setq config-python-project-name project-name)
      (message "ℹ️  Virtual environment activated for project: %s" project-name)
      (force-mode-line-update t))))))

;; Configure pyvenv when available
(when
 (featurep 'pyvenv)
 (pyvenv-mode 1)
 ;; Show virtual environment in modeline with custom format
 (setq
  pyvenv-mode-line-indicator
  '(pyvenv-virtual-env-name ("[venv: " config-python-project-name "] ")))
 (add-hook 'pyvenv-post-deactivate-hooks #'config-pyvenv-post-deactivate)
 (add-hook 'pyvenv-post-activate-hooks #'config-pyvenv-post-activate))

;; Try use-package if available, otherwise use require
(if
 (fboundp 'use-package)
 (use-package
  pyvenv
  :config (pyvenv-mode 1)
  ;; Show virtual environment in modeline with custom format
  (setq
   pyvenv-mode-line-indicator
   '(pyvenv-virtual-env-name ("[venv: " config-python-project-name "] ")))
  (add-hook 'pyvenv-post-deactivate-hooks #'config-pyvenv-post-deactivate)
  (add-hook 'pyvenv-post-activate-hooks #'config-pyvenv-post-activate))
 ;; Fallback when use-package is not available
 (progn
  (when
   (require 'pyvenv nil t)
   (pyvenv-mode 1)
   ;; Show virtual environment in modeline with custom format
   (setq
    pyvenv-mode-line-indicator
    '(pyvenv-virtual-env-name ("[venv: " config-python-project-name "] ")))
   (add-hook 'pyvenv-post-deactivate-hooks #'config-pyvenv-post-deactivate)
   (add-hook 'pyvenv-post-activate-hooks #'config-pyvenv-post-activate))))

;; Automatically activate virtual environment when opening Python files
(defun
 pyvenv-auto-activate
 ()
 "Automatically activate virtual environment if found in project."
 (interactive)
 (let* ((current-dir (expand-file-name default-directory))
        (project-root
         (or
          (locate-dominating-file current-dir ".git")
          (locate-dominating-file current-dir "pyproject.toml")
          (locate-dominating-file current-dir "requirements.txt")
          current-dir))
        (venv-path (when project-root (expand-file-name "venv" project-root))))
   ;; Only activate if we found a venv and it's not already active
   (when
    (and
     venv-path (file-directory-p venv-path)
     (not
      (and
       (boundp 'pyvenv-virtual-env)
       pyvenv-virtual-env
       (string-equal pyvenv-virtual-env venv-path))))
    (if
     (fboundp 'pyvenv-activate)
     (progn
      (pyvenv-activate venv-path)
      ;; Update Python shell to use the virtual environment's Python
      (let* ((venv-python (expand-file-name "bin/python" venv-path))
             (venv-parent-dir (file-name-directory (directory-file-name venv-path)))
             (project-name (file-name-nondirectory (directory-file-name venv-parent-dir))))
        (when
         (file-executable-p venv-python)
         (setq python-shell-interpreter venv-python)
         (message "ℹ️  Python virtual environment activated: %s" project-name))
        ;; Set the project name globally for modeline display and force update
        (setq-default config-python-project-name project-name)
        (setq config-python-project-name project-name)
        (force-mode-line-update t)))
     (message "⚠️  Warning: pyvenv-activate function not available")))))

;; Auto-activate when opening Python files (only use python-mode-hook to avoid duplicates)
(add-hook 'python-mode-hook #'pyvenv-auto-activate)

;; Ensure modeline updates when switching buffers
(add-hook
 'buffer-list-update-hook
 (lambda
  () "Ensure modeline updates when switching buffers with active virtual environment."
  (when
   (and
    (boundp 'pyvenv-virtual-env) pyvenv-virtual-env config-python-project-name)
   (force-mode-line-update))))

;; Make this module available for loading with (require 'venv)
(provide 'venv)
(message
 "venv.el loaded (%.2fs)"
 (float-time (time-subtract (current-time) config-load-start-time)))
