;;; pyvenv-remote.el --- TRAMP-aware Python Virtual Environment Support -*- lexical-binding: t -*-
;;; Commentary:
;;      TRAMP integration with proper remote virtual environment detection.
;;      Provides seamless Python virtual environment support for remote files.

;;; Code:
(require 'core-utils)
(require 'core-logging)
(require 'pyvenv-config)
(require 'pyvenv-utils)
(require 'python-utils)
(require 'tramp-utils)
(require 'lang-utils)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 pyvenv-remote-find-venv (remote-dir)
 "Find virtual environment for remote directory.
REMOTE-DIR is the remote directory to search for a virtual environment.
First tries to find it remotely, falls back to local equivalent if needed."
 (core-message-debug "Searching for venv in: %s" (abbreviate-file-name remote-dir))
 (if
  (file-remote-p remote-dir)
  ;; Try remote search first
  (let ((remote-venv (pyvenv-remote-search-venv remote-dir)))
    (if
     remote-venv (progn (core-message-debug "Found remote venv: %s" remote-venv) remote-venv)
     ;; Fallback to local equivalent search
     (let* ((local-dir (file-local-name remote-dir))
            (default-directory local-dir))
       (when
        (file-exists-p local-dir)
        (core-message-loading "Falling back to local venv search for remote file")
        (pyvenv-find-venv)))))
  ;; Local directory - use existing function
  (pyvenv-find-venv)))

(defun
 pyvenv-remote-search-venv (remote-dir)
 "Search for virtual environment in remote directory using centralized detection.
REMOTE-DIR is the remote directory to search for a virtual environment.
Uses python-utils-find-venv-path which is TRAMP-compatible via `locate-dominating-file'."
 (python-utils-find-venv-path remote-dir))

(defun
 pyvenv-remote-activate () "TRAMP-aware virtual environment activation."
 (if
  (tramp-is-remote-file)
  ;; Remote file handling
  (let* ((remote-dir default-directory)
         (host (file-remote-p remote-dir 'host)))

    ;; Find venv using proper remote detection
    (let ((venv-path (pyvenv-remote-find-venv remote-dir)))
      (if
       venv-path
       (progn
        ;; Setup connection profile with remote path
        (pyvenv-remote-setup-connection host venv-path)

        ;; Update project state (use buffer-local variables for remote files)
        (let* ((project-dir (file-name-directory (directory-file-name venv-path)))
               (project-name (python-utils-extract-project-name project-dir)))
          ;; Set buffer-local variables so they don't interfere with local Python files
          (setq-local pyvenv-project-root project-dir)
          (setq-local pyvenv-project-name project-name)
          ;; Set pyvenv-virtual-env buffer-locally to the remote venv path
          ;; This is used by the modeline and other tools
          (setq-local pyvenv-virtual-env venv-path)
          (core-message-success "Activated Python venv for project: %s" project-name)

          ;; Log detected Python version for user feedback
          (let ((python-version (pyvenv-get-python-version venv-path)))
            (if
             python-version
             (core-message-info "Using Python %s from virtual environment" python-version)
             (core-message-warning "Could not detect Python version in virtual environment")))

          ;; Update python-shell-interpreter for doom-modeline display
          (pyvenv-update-shell-interpreter))))))

  ;; Local file: use existing activation
  (when (fboundp 'pyvenv-auto-activate) (pyvenv-auto-activate))))

(defun
 pyvenv-remote-setup-connection (host venv-path)
 "Setup connection-local variables for virtual environment.
HOST is the remote host identifier.
VENV-PATH is the path to the virtual environment on the remote host."
 (let ((profile-name
        (intern (format "pyvenv-remote-%s" (secure-hash 'md5 (format "%s-%s" host venv-path))))))
   (tramp-create-python-connection-profile profile-name host venv-path)))

;; Replace existing hooks for both python-mode and python-ts-mode
(lang-remove-dual-mode-hooks 'python-mode-hook 'python-ts-mode-hook #'pyvenv-auto-activate)
;; Add pyvenv-remote-activate back for virtual environment detection and modeline
(lang-add-dual-mode-hooks 'python-mode-hook 'python-ts-mode-hook #'pyvenv-remote-activate)

(core-message-debug "TRAMP-aware pyvenv support loaded")
(provide 'pyvenv-remote)
;;; pyvenv-remote.el ends here
