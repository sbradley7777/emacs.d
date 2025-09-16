;;; tramp-utils.el --- TRAMP utility functions -*- lexical-binding: t -*-
;;; Commentary:
;;      Utility functions for TRAMP configuration and management,
;;      specifically for Python development support.

(require 'core-utils)
(require 'tramp)

(with-load-timing
 "tramp-utils.el"

 (defun
  tramp-setup-python-paths
  ()
  "Add Python paths to tramp-remote-path using constants."
  (require 'python-constants)
  (dolist (path python-tramp-remote-bin-paths) (add-to-list 'tramp-remote-path path))
  ;; Add user's remote PATH
  (add-to-list 'tramp-remote-path 'tramp-own-remote-path))

 (defun
  tramp-setup-python-environment
  ()
  "Configure Python environment variables for TRAMP."
  (require 'python-constants)
  (dolist (env python-tramp-environment-vars) (add-to-list 'tramp-remote-process-environment env)))

 (defun
  tramp-create-python-connection-profile (profile-name host venv-path &optional python-path)
  "Create connection-local profile for Python virtual environment.
PROFILE-NAME: Symbol name for the profile
HOST: Remote hostname
VENV-PATH: Path to virtual environment on remote host
PYTHON-PATH: Optional additional Python path"
  (let ((venv-bin (expand-file-name "bin" venv-path))
        (env-vars
         (append
          (list (format "VIRTUAL_ENV=%s" venv-path))
          (when python-path (list (format "PYTHONPATH=%s" python-path)))
          python-tramp-environment-vars)))

    (connection-local-set-profile-variables
     profile-name
     `((tramp-remote-path . (,venv-bin tramp-own-remote-path tramp-default-remote-path))
       (tramp-remote-process-environment . ,env-vars)))

    (connection-local-set-profiles `(:application tramp :machine ,host) profile-name)))

 (defun
  tramp-is-remote-file
  (&optional file)
  "Check if FILE (or current buffer file) is accessed via TRAMP."
  (file-remote-p (or file default-directory)))

 (message "🔧 TRAMP utilities loaded"))

(provide 'tramp-utils)
;;; tramp-utils.el ends here
