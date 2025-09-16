;;; pyvenv-remote.el --- TRAMP-aware Python Virtual Environment Support -*- lexical-binding: t -*-
;;; Commentary:
;;      TRAMP integration with proper remote virtual environment detection.
;;      Provides seamless Python virtual environment support for remote files.

(require 'core-utils)
(require 'pyvenv-config)
(require 'tramp-utils)

(with-load-timing
 "pyvenv-remote.el"

 (defvar
  pyvenv-remote-venv-cache
  (make-hash-table :test 'equal)
  "Cache of virtual environments per TRAMP connection.")

 (defun
  pyvenv-remote-find-venv (remote-dir)
  "Find virtual environment for remote directory.
First tries to find it remotely, falls back to local equivalent if needed."
  (if
   (file-remote-p remote-dir)
   ;; Try remote search first
   (let ((remote-venv (pyvenv-remote-search-venv remote-dir)))
     (if
      remote-venv remote-venv
      ;; Fallback to local equivalent search
      (let* ((local-dir (file-local-name remote-dir))
             (default-directory local-dir))
        (when
         (file-exists-p local-dir)
         (message "🔍 Falling back to local venv search for remote file")
         (pyvenv-find-venv)))))
   ;; Local directory - use existing function
   (pyvenv-find-venv)))

 (defun
  pyvenv-remote-search-venv
  (remote-dir)
  "Search for virtual environment in remote directory and parent directories."
  ;; Search up the directory tree for project markers
  (let ((current-dir remote-dir)
        (project-root nil))

    (while
     (and current-dir (not project-root) (not (string= current-dir "/")))

     ;; Look for project markers in current directory
     (setq
      project-root
      (cl-some
       (lambda
        (marker)
        (let ((marker-path (expand-file-name marker current-dir)))
          (when (file-exists-p marker-path) current-dir)))
       pyvenv-project-markers))

     ;; Move to parent directory if no marker found
     (unless
      project-root
      (let ((parent (file-name-directory (directory-file-name current-dir))))
        (setq current-dir (if (string= parent current-dir) nil parent)))))

    ;; If we found a project root, look for venv
    (when
     project-root
     (let ((venv-path (expand-file-name pyvenv-venv-directory-name project-root)))
       (when (file-directory-p venv-path) venv-path)))))

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
         ;; For remote venv, we need to activate the local equivalent for pyvenv
         (let ((local-venv-path
                (if (file-remote-p venv-path) (file-local-name venv-path) venv-path)))
           (when
            (and (fboundp 'pyvenv-activate) (file-exists-p local-venv-path))
            (pyvenv-activate local-venv-path)))

         ;; Setup connection profile with remote path
         (pyvenv-remote-setup-connection host venv-path)

         ;; Update project state for modeline
         (let* ((project-dir (file-name-directory (directory-file-name venv-path)))
                (project-name (file-name-nondirectory (directory-file-name project-dir))))
           (setq pyvenv-project-root project-dir)
           (setq pyvenv-project-name project-name)
           (setq pyvenv-current-project-name project-name))

         (message
          "✅ Activated remote Python venv: %s"
          (file-name-nondirectory (directory-file-name venv-path)))
         (pyvenv-update-modeline))
        ;; No venv found
        (setq pyvenv-current-project-name "inactive") (pyvenv-update-modeline))))

   ;; Local file: use existing activation
   (when (fboundp 'pyvenv-auto-activate) (pyvenv-auto-activate))))

 (defun
  pyvenv-remote-setup-connection
  (host venv-path)
  "Setup connection-local variables for virtual environment."
  (let ((profile-name
         (intern (format "pyvenv-remote-%s" (secure-hash 'md5 (format "%s-%s" host venv-path))))))
    (tramp-create-python-connection-profile profile-name host venv-path)))

 ;; Replace existing hooks
 (remove-hook 'python-mode-hook #'pyvenv-auto-activate)
 (remove-hook 'python-mode-hook #'smart-pyvenv-activate)
 (add-hook 'python-mode-hook #'pyvenv-remote-activate)

 (message "🔧 TRAMP-aware pyvenv support loaded"))

(provide 'pyvenv-remote)
;;; pyvenv-remote.el ends here
