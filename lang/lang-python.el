;;; lang-python.el --- Python Language Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Python and Elpy configuration

(message "Loading lang-python.el...")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Python-specific indentation settings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-hook 'python-mode-hook
          (lambda ()
            (setq python-indent-guess-indent-offset t) ; python-indent-guess-indent-offset. When set to a non-nil value, it attempts to guess the indentation offset based on the existing indentation in the file.
            (setq indent-tabs-mode nil) ; Use spaces
            (setq python-indent 4)))   ; 4 spaces for indentation

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Virtual environment support
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Add virtual environment support for better Python project management
(use-package pyvenv
             :config
             (pyvenv-mode 1)

             ;; Variable to hold the project name for modeline display
             (defvar pyvenv-project-name nil
               "Name of the project containing the current virtual environment.")

             ;; Make pyvenv-project-name a global variable that persists across buffers
             (setq-default pyvenv-project-name nil)

             ;; Show virtual environment in modeline with custom format
             (setq pyvenv-mode-line-indicator
                   '(pyvenv-virtual-env-name
                     ("[venv: " pyvenv-project-name "] ")))

             ;; Clear project name when deactivating virtual environment
             (add-hook 'pyvenv-post-deactivate-hooks
                       (lambda ()
                         (setq-default pyvenv-project-name nil)
                         (setq pyvenv-project-name nil)
                         (force-mode-line-update t)))

             ;; Add our hook AFTER Elpy's hook to ensure our project name persists
             (add-hook 'pyvenv-post-activate-hooks
                       (lambda ()
                         (when pyvenv-virtual-env
                           ;; Small delay to ensure we run after all other hooks
                           (run-with-timer 0.1 nil
                                           (lambda ()
                                             (let ((project-name (file-name-nondirectory
                                                                  (directory-file-name
                                                                   (file-name-directory
                                                                    (directory-file-name pyvenv-virtual-env))))))
                                               (setq-default pyvenv-project-name project-name)
                                               (setq pyvenv-project-name project-name)
                                               (message "POST-ACTIVATE HOOK: Set project name to: %s" project-name)
                                               (force-mode-line-update t))))))
                       90) ; Higher priority to run after Elpy's hook

             ;; Automatically activate virtual environment when opening Python files
             (defun pyvenv-auto-activate ()
               "Automatically activate virtual environment if found in project."
               (interactive)
               (let* ((current-dir (expand-file-name default-directory))
                      (git-root (locate-dominating-file current-dir ".git"))
                      (pyproject-root (locate-dominating-file current-dir "pyproject.toml"))
                      (requirements-root (locate-dominating-file current-dir "requirements.txt"))
                      (project-root (or git-root pyproject-root requirements-root current-dir))
                      (venv-path (when project-root
                                   (expand-file-name "venv" project-root))))
                 (when (and venv-path
                            (file-directory-p venv-path)
                            (not (and (boundp 'pyvenv-virtual-env)
                                      pyvenv-virtual-env
                                      (string-equal pyvenv-virtual-env venv-path))))
                   (pyvenv-activate venv-path)
                   ;; Update both Python shell and Elpy RPC to use the virtual environment's Python
                   (let ((venv-python (expand-file-name "bin/python" venv-path))
                         (project-name (file-name-nondirectory
                                        (directory-file-name
                                         (file-name-directory
                                          (directory-file-name venv-path))))))
                     (when (file-executable-p venv-python)
                       (setq python-shell-interpreter venv-python)
                       (setq elpy-rpc-python-command venv-python)
                       (message "Updated Python interpreter and Elpy RPC to: %s" python-shell-interpreter))
                     ;; Set the project name globally for modeline display
                     (setq-default pyvenv-project-name project-name)
                     (setq pyvenv-project-name project-name)
                     ;; Force modeline update
                     (force-mode-line-update t))
                   (message "Activated virtual environment: %s" venv-path))))

             ;; Auto-activate when opening Python files
             (add-hook 'python-mode-hook
                       #'pyvenv-auto-activate)
             (add-hook 'find-file-hook
                       (lambda ()
                         (when (derived-mode-p 'python-mode)
                           (pyvenv-auto-activate))))

             ;; Ensure modeline updates when switching buffers
             (add-hook 'buffer-list-update-hook
                       (lambda ()
                         (when (and pyvenv-virtual-env pyvenv-project-name)
                           (force-mode-line-update)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Python shell integration improvements
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Disable native completion to prevent hangs with certain Python setups
(setq python-shell-completion-native-enable nil)

;; Disable prompt detection warnings for cleaner REPL experience
(setq python-shell-prompt-detect-failure-warning nil)

;; Make this module available for loading with (require 'lang-python)
(provide 'lang-python)
(message "lang-python.el loaded successfully.")
