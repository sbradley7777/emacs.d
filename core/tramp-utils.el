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

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Eglot + TRAMP Integration Utilities
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (defun
  eglot-remote-find-pylsp (&optional remote-dir)
  "Find pylsp executable for remote directory using priority-ordered paths.
 REMOTE-DIR defaults to current directory. Returns full remote path or nil."
  (require 'python-constants)
  (let ((dir (or remote-dir default-directory)))
    (when
     (file-remote-p dir)
     (cl-some
      (lambda
       (path)
       (let ((full-path (expand-file-name path dir)))
         ;; Test actual remote execution instead of file-executable-p
         (let* ((test-cmd (format "command -v %s || test -x %s" path path))
                (result
                 (condition-case err
                     (string-trim (shell-command-to-string test-cmd))
                   (error
                    nil))))
           (when
            (and
             result
             (not (string-empty-p result))
             (not (string-match-p "not found\\|No such file" result)))
            (let ((user (file-remote-p dir 'user))
                  (host (file-remote-p dir 'host)))
              (message "✅ Found working pylsp (remote): %s@%s:%s" user host path))
            full-path))))
      eglot-remote-pylsp-paths))))

 (defun
  eglot-remote-server-contact (&optional remote-dir)
  "Create eglot server contact for remote pylsp with proper TRAMP integration.
 Returns list suitable for eglot-server-programs or nil if not found."
  (let ((pylsp-path (eglot-remote-find-pylsp remote-dir)))
    (if pylsp-path (list pylsp-path) (progn (message "⚠️ No remote pylsp found") nil))))

 (defun
  eglot-remote-test-pylsp
  (&optional remote-dir)
  "Test pylsp execution on remote host for debugging purposes."
  (interactive)
  (require 'python-constants)
  (let ((dir (or remote-dir default-directory)))
    (message "🔧 === COMPREHENSIVE EGLOT+PYLSP DEBUG TEST ===")
    (message "🔧 Directory: %s" dir)
    (message "🔧 Is remote: %s" (file-remote-p dir))
    (message "🔧 Remote host: %s" (file-remote-p dir 'host))
    (message "🔧 Remote method: %s" (file-remote-p dir 'method))

    (if
     (file-remote-p dir)
     (progn
      (message "🔧 Testing remote pylsp paths...")
      (message "🔧 Available paths to test: %s" eglot-remote-pylsp-paths)

      (dolist
       (path eglot-remote-pylsp-paths)
       (let* ((full-path (expand-file-name path dir)))
         (message "🔧 --- Testing path: %s ---" path)
         (message "🔧 Full path: %s" full-path)
         (message "🔧 file-exists-p: %s" (file-exists-p full-path))
         (message "🔧 file-executable-p: %s" (file-executable-p full-path))
         (message "🔧 file-readable-p: %s" (file-readable-p full-path))

         ;; Test actual execution
         (let* ((test-cmd (format "%s --help 2>&1 | head -1" full-path))
                (result
                 (condition-case err
                     (shell-command-to-string test-cmd)
                   (error
                    (format "Error: %s" (error-message-string err))))))
           (message "🔧 Execution test: %s" (string-trim result)))))

      ;; Test our detection function
      (message "🔧 --- Testing eglot-remote-find-pylsp ---")
      (let ((found-path (eglot-remote-find-pylsp dir)))
        (message "🔧 Detection result: %s" found-path))

      ;; Test server contact creation
      (message "🔧 --- Testing eglot-remote-server-contact ---")
      (let ((server-contact (eglot-remote-server-contact dir)))
        (message "🔧 Server contact result: %s" server-contact)))

     (message "🔧 Local directory - testing local pylsp path: %s" eglot-pylsp-path)
     (message "🔧 Local file-exists-p: %s" (file-exists-p eglot-pylsp-path))
     (message "🔧 Local file-executable-p: %s" (file-executable-p eglot-pylsp-path)))

    (message "🔧 === END DEBUG TEST ===")))

 (message "🔧 TRAMP utilities loaded"))

(provide 'tramp-utils)
;;; tramp-utils.el ends here
