;;; pyvenv-remote.el --- Python Virtual Environment Remote/TRAMP Support -*- lexical-binding: t -*-
;;; Commentary:
;;      TRAMP-aware virtual environment management that properly handles
;;      remote Python development over SSH. This module fixes issues with
;;      pyvenv when working with remote files via TRAMP.

(require 'core-utils)

(with-load-timing
 "pyvenv-remote.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Debugging support for remote pyvenv issues
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (defvar
  pyvenv-remote-debug nil
  "Enable debugging output for remote pyvenv operations.
Set to t to enable detailed logging of remote pyvenv activation attempts.")


 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Remote-aware virtual environment functions
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;; Universal virtual environment activation for both local and remote (TRAMP) environments
 (defun
  force-remote-pyvenv-activation
  ()
  "Force activation of virtual environment with proper modeline display for both local and remote files."
  (interactive)
  (when
   pyvenv-remote-debug
   (message "🐛 [pyvenv-remote] Checking for pyvenv activation in: %s" default-directory))
  (let* ((current-dir (expand-file-name default-directory))
         (project-root
          (or
           (locate-dominating-file current-dir ".git")
           (locate-dominating-file current-dir "pyproject.toml")
           (locate-dominating-file current-dir "requirements.txt")
           current-dir))
         (venv-path (when project-root (expand-file-name "venv" project-root))))

    (when
     pyvenv-remote-debug
     (message "🐛 [pyvenv-remote] Project root: %s, venv path: %s" project-root venv-path))
    (when
     venv-path
     (when
      pyvenv-remote-debug
      (message
       "🐛 [pyvenv-remote] Venv exists: %s, is remote: %s"
       (file-directory-p venv-path)
       (file-remote-p venv-path))))

    (when
     (and
      venv-path (file-directory-p venv-path)
      (or
       (not (boundp 'pyvenv-virtual-env))
       (not pyvenv-virtual-env)
       (not (string-equal pyvenv-virtual-env venv-path))))

     (when
      pyvenv-remote-debug
      (message
       "🐛 [pyvenv-remote] Activating %s venv: %s"
       (if (file-remote-p venv-path) "remote" "local")
       venv-path))
     (when
      (fboundp 'pyvenv-activate)
      (pyvenv-activate venv-path)
      (when pyvenv-remote-debug (message "🐛 [pyvenv-remote] pyvenv-activate completed"))

      ;; Set Python interpreter (handle both local and remote paths)
      (let* ((venv-python-full-path (expand-file-name "bin/python" venv-path))
             (venv-python-local-path
              (if
               (file-remote-p venv-python-full-path)
               (file-local-name venv-python-full-path)
               venv-python-full-path)))
        (when
         pyvenv-remote-debug
         (message
          "🐛 [pyvenv-remote] Setting python interpreter: %s -> %s"
          venv-python-full-path
          venv-python-local-path))
        (setq python-shell-interpreter venv-python-local-path))

      ;; Force update of modeline variables after a brief delay
      (run-with-timer
       0.2 nil
       (lambda
        ()
        (when
         pyvenv-remote-debug
         (message "🐛 [pyvenv-remote] Timer callback: updating modeline variables"))
        (when
         (and (boundp 'pyvenv-virtual-env) pyvenv-virtual-env)
         (let* ((venv-parent-dir (file-name-directory (directory-file-name pyvenv-virtual-env)))
                (project-name (file-name-nondirectory (directory-file-name venv-parent-dir))))
           (when
            pyvenv-remote-debug
            (message "🐛 [pyvenv-remote] Setting project name: %s" project-name))
           (setq config-python-project-name project-name)
           (setq-default config-python-project-name project-name)
           (force-mode-line-update t)))))))))

 ;; Fix for handling remote Python interpreter paths
 (defun
  fix-remote-python-interpreter () "Fix python-shell-interpreter if it's set to a remote path."
  (when
   (and
    (boundp 'python-shell-interpreter)
    python-shell-interpreter
    (file-remote-p python-shell-interpreter))
   (when
    pyvenv-remote-debug
    (message
     "🐛 [pyvenv-remote] Fixing remote python interpreter: %s -> %s"
     python-shell-interpreter
     (file-local-name python-shell-interpreter)))
   (setq python-shell-interpreter (file-local-name python-shell-interpreter))))

 ;; Safe version of pyvenv post-activate that doesn't break on remote files
 (defun
  safe-pyvenv-post-activate
  ()
  "Safe version of pyvenv post-activate that doesn't break on remote files."
  (when
   pyvenv-remote-debug
   (message
    "🐛 [pyvenv-remote] Safe post-activate called with venv: %s"
    (when (boundp 'pyvenv-virtual-env) pyvenv-virtual-env)))
  (when
   pyvenv-virtual-env
   (let* ((venv-parent-dir (file-name-directory (directory-file-name pyvenv-virtual-env)))
          (project-name (file-name-nondirectory (directory-file-name venv-parent-dir)))
          (venv-python (expand-file-name "bin/python" pyvenv-virtual-env)))
     (when
      pyvenv-remote-debug
      (message
       "🐛 [pyvenv-remote] Project: %s, Python path: %s, is remote: %s"
       project-name
       venv-python
       (file-remote-p venv-python)))
     ;; Only set interpreter if it's not remote or convert to local path
     (when
      (file-exists-p venv-python)
      (let ((interpreter
             (if (file-remote-p venv-python) (file-local-name venv-python) venv-python)))
        (when
         pyvenv-remote-debug (message "🐛 [pyvenv-remote] Setting interpreter: %s" interpreter))
        (setq python-shell-interpreter interpreter)))
     ;; Set project name for modeline
     (when
      pyvenv-remote-debug
      (message "🐛 [pyvenv-remote] Setting modeline project name: %s" project-name))
     (setq config-python-project-name project-name)
     (setq-default config-python-project-name project-name)
     (force-mode-line-update t))))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Hook management for remote pyvenv support
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;; Remove the original auto-activation that causes problems with remote files
 (when (fboundp 'pyvenv-auto-activate) (remove-hook 'python-mode-hook #'pyvenv-auto-activate))

 ;; Add our remote-aware activation function
 (add-hook 'python-mode-hook #'force-remote-pyvenv-activation)
 (add-hook 'python-mode-hook #'fix-remote-python-interpreter)

 ;; Replace the problematic post-activate hook with our safe version
 (when
  (fboundp 'config-pyvenv-post-activate)
  (remove-hook 'pyvenv-post-activate-hooks #'config-pyvenv-post-activate))
 (add-hook 'pyvenv-post-activate-hooks #'safe-pyvenv-post-activate)

 (when pyvenv-remote-debug (message "🐛 [pyvenv-remote] Hook management completed"))
 (message "🔧 Remote pyvenv TRAMP support loaded"))


;; Make this module available for loading with (require 'pyvenv-remote)
(provide 'pyvenv-remote)

;;; pyvenv-remote.el ends here
