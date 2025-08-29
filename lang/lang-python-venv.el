;;; lang-python-venv.el --- Python Virtual Environment Management -*- lexical-binding: t -*-
;;; Commentary:
;;      Complete virtual environment management with pyvenv integration,
;;      auto-activation, modeline display, and project detection.

(defvar config-load-start-time (current-time))
(message "Loading lang-python-venv.el...")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Virtual environment support
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Add virtual environment support for better Python project management
(use-package pyvenv
             :config
             (pyvenv-mode 1)

             ;; Variable to hold the project name for modeline display (global variable that persists across buffers)
             (defvar config-python-project-name nil "Name of the project containing the current virtual environment.")
             (setq-default config-python-project-name nil)

             ;; Show virtual environment in modeline with custom format
             (setq pyvenv-mode-line-indicator
                   '(pyvenv-virtual-env-name
                     ("[venv: " config-python-project-name "] ")))

             ;; Clear project name when deactivating virtual environment
             (add-hook 'pyvenv-post-deactivate-hooks
                       (lambda ()
                         "Clear project name variables when deactivating virtual environment."
                         (setq-default config-python-project-name nil)
                         (setq config-python-project-name nil)
                         (force-mode-line-update t)))

             ;; Add our hook AFTER Elpy's hook to ensure our project name persists
             (add-hook 'pyvenv-post-activate-hooks
                       (lambda ()
                         "Extract and set project name from virtual environment path for modeline display."
                         (when pyvenv-virtual-env
                           ;; Small delay to ensure we run after all other hooks
                           (run-with-timer 0.1 nil
                                           (lambda ()
                                             "Update project name variables with extracted project name."
                                             (let* ((venv-parent-dir (file-name-directory (directory-file-name pyvenv-virtual-env)))
                                                    (project-name (file-name-nondirectory (directory-file-name venv-parent-dir))))
                                               (setq-default config-python-project-name project-name)
                                               (setq config-python-project-name project-name)
                                               (message "POST-ACTIVATE HOOK: Set project name to: %s" project-name)
                                               (force-mode-line-update t))))))
                       90)                           ; Higher priority to run after Elpy's hook

             ;; Automatically activate virtual environment when opening Python files
             (defun pyvenv-auto-activate ()
               "Automatically activate virtual environment if found in project."
               (interactive)
               (let* ((current-dir (expand-file-name default-directory))
                      (project-root (or (locate-dominating-file current-dir ".git")
                                        (locate-dominating-file current-dir "pyproject.toml")
                                        (locate-dominating-file current-dir "requirements.txt")
                                        current-dir))
                      (venv-path (when project-root (expand-file-name "venv" project-root))))
                 (when (and venv-path (file-directory-p venv-path)
                            (not (and (boundp 'pyvenv-virtual-env) pyvenv-virtual-env
                                      (string-equal pyvenv-virtual-env venv-path))))
                   (pyvenv-activate venv-path)
                   ;; Update both Python shell and Elpy RPC to use the virtual environment's Python
                   (let* ((venv-python (expand-file-name "bin/python" venv-path))
                          (venv-parent-dir (file-name-directory (directory-file-name venv-path)))
                          (project-name (file-name-nondirectory (directory-file-name venv-parent-dir))))
                     (when (file-executable-p venv-python)
                       (setq python-shell-interpreter venv-python
                             elpy-rpc-python-command venv-python)
                       (message "Updated Python interpreter and Elpy RPC to: %s" python-shell-interpreter))
                     ;; Set the project name globally for modeline display and force update
                     (setq-default config-python-project-name project-name)
                     (setq config-python-project-name project-name)
                     (force-mode-line-update t))
                   (message "Activated virtual environment: %s" venv-path))))

             ;; Auto-activate when opening Python files
             (add-hook 'python-mode-hook #'pyvenv-auto-activate)
             (add-hook 'find-file-hook (lambda ()
                                         "Auto-activate virtual environment for Python files."
                                         (when (derived-mode-p 'python-mode) (pyvenv-auto-activate))))

             ;; Ensure modeline updates when switching buffers
             (add-hook 'buffer-list-update-hook (lambda ()
                                                  "Ensure modeline updates when switching buffers with active virtual environment."
                                                  (when (and pyvenv-virtual-env config-python-project-name)
                                                    (force-mode-line-update)))))

;; Make this module available for loading with (require 'lang-python-venv)
(provide 'lang-python-venv)
(message "lang-python-venv.el loaded (%.2fs)"
         (float-time (time-subtract (current-time) config-load-start-time)))
