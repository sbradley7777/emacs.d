;;; tramp-utils.el --- TRAMP utility functions -*- lexical-binding: t -*-
;;; Commentary:
;;      Utility functions for TRAMP configuration and management,
;;      specifically for Python development support.

;;; Code:
(require 'core-utils)
(require 'tramp)
(require 'core-logging)

;; Declare correct signature for executable-find (Emacs 27.1+)
(declare-function executable-find "files" (command &optional remote))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
 tramp-is-remote-file (&optional file)
 "Check if FILE (or current buffer file) is accessed via TRAMP.
This function is deprecated. Use `core-utils-is-remote-file' instead."
 (core-utils-is-remote-file file))

(defun
 tramp-utils-show-connection-info
 ()
 "Display TRAMP connection or local directory information in minibuffer."
 (interactive)
 (if-let* ((host (file-remote-p default-directory 'host)))
   (let ((method (file-remote-p default-directory 'method))
         (user (file-remote-p default-directory 'user)))
     (message
      "Remote Connection | Method: %s | User: %s | Host: %s | Path: %s"
      method
      (or user "default")
      host
      (file-remote-p default-directory 'localname)))
   (core-message-info "Local Directory: %s" (abbreviate-file-name default-directory))))

(core-message-debug "TRAMP utilities loaded")
(provide 'tramp-utils)
;;; tramp-utils.el ends here
