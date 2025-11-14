;;; tramp-utils.el --- TRAMP utility functions -*- lexical-binding: t -*-
;;; Commentary:
;;      Utility functions for TRAMP configuration and management,
;;      specifically for Python development support.

;;; Code:
(require 'core-utils)
(require 'tramp)
(require 'core-logging)

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
         (when python-path (list (format "PYTHONPATH=%s" python-path))))))

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
(defun
 core-utils-check-command-in-path-remote-host (command)
 "Check if COMMAND exists in PATH on remote host (for TRAMP buffers).
Returns t if command is found, nil otherwise.
Only works when called from a buffer visiting a remote file via TRAMP."
 (require 'core-utils)
 (if
  (not (file-remote-p default-directory))
  (progn (core-message-warning "Not a remote file - cannot check remote host PATH") nil)
  (let* ((host (file-remote-p default-directory 'host))
         (command-path (executable-find command t)))
    (if
     command-path
     (progn (core-utils-format-command-found-message command command-path host "remote") t)
     (core-utils-format-command-not-found-message command host "remote")
     nil))))

(core-message-debug "TRAMP utilities loaded")
(provide 'tramp-utils)
;;; tramp-utils.el ends here
