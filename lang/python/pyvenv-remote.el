;;; pyvenv-remote.el --- Python Virtual Environment Remote/TRAMP Support -*- lexical-binding: t -*-
;;; Commentary:
;;      TRAMP-aware virtual environment management that properly handles
;;      remote Python development over SSH. This module fixes issues with
;;      pyvenv when working with remote files via TRAMP.

(require 'core-utils)
(require 'pyvenv-config)

(with-load-timing
 "pyvenv-remote.el"

 (defvar pyvenv-remote-debug t "Enable debugging output for remote pyvenv operations.")

 (defun
  smart-pyvenv-activate
  ()
  "TRAMP-aware pyvenv activation with modeline support."
  (when pyvenv-remote-debug (message "🐛 [pyvenv] ========== STARTING ACTIVATION =========="))
  (when pyvenv-remote-debug (message "🐛 [pyvenv] Current directory: %s" default-directory))
  (when
   pyvenv-remote-debug (message "🐛 [pyvenv] File remote?: %s" (file-remote-p default-directory)))
  (when
   pyvenv-remote-debug
   (message
    "🐛 [pyvenv] Current pyvenv-virtual-env: %s"
    (if (boundp 'pyvenv-virtual-env) pyvenv-virtual-env "UNBOUND")))

  (if
   (file-remote-p default-directory)
   ;; Remote file handling
   (let ((local-dir (file-local-name default-directory)))
     (when
      pyvenv-remote-debug (message "🐛 [pyvenv] REMOTE MODE: %s -> %s" default-directory local-dir))

     (let ((default-directory local-dir))
       (when
        pyvenv-remote-debug
        (message
         "🐛 [pyvenv] About to call pyvenv-auto-activate with local-dir: %s" default-directory))
       (when pyvenv-remote-debug (message "🐛 [pyvenv] Checking project markers:"))
       (when
        pyvenv-remote-debug
        (message "🐛 [pyvenv]   .git: %s" (locate-dominating-file default-directory ".git")))
       (when
        pyvenv-remote-debug
        (message
         "🐛 [pyvenv]   pyproject.toml: %s"
         (locate-dominating-file default-directory "pyproject.toml")))
       (when
        pyvenv-remote-debug
        (message
         "🐛 [pyvenv]   requirements.txt: %s"
         (locate-dominating-file default-directory "requirements.txt")))

       (when
        (fboundp 'pyvenv-auto-activate) (pyvenv-auto-activate)
        (when
         pyvenv-remote-debug
         (message
          "🐛 [pyvenv] After pyvenv-auto-activate: %s"
          (if (boundp 'pyvenv-virtual-env) pyvenv-virtual-env "STILL UNBOUND")))
        ;; If original failed, try enhanced search
        (when
         (not pyvenv-virtual-env)
         (when
          pyvenv-remote-debug (message "🐛 [pyvenv] Original failed, trying enhanced search..."))
         (let ((venv-location (locate-dominating-file default-directory "venv")))
           (when
            pyvenv-remote-debug
            (message "🐛 [pyvenv] Enhanced search - venv location: %s" venv-location))
           (when
            venv-location
            (let ((venv-path (expand-file-name "venv" venv-location)))
              (when
               pyvenv-remote-debug
               (message "🐛 [pyvenv] Enhanced search - full venv path: %s" venv-path))
              (when
               pyvenv-remote-debug
               (message
                "🐛 [pyvenv] Enhanced search - venv exists?: %s" (file-directory-p venv-path)))
              (when
               (and venv-path (file-directory-p venv-path))
               (when
                pyvenv-remote-debug
                (message "🐛 [pyvenv] Enhanced search - activating venv: %s" venv-path))
               (when
                (fboundp 'pyvenv-activate) (pyvenv-activate venv-path)
                (when
                 pyvenv-remote-debug
                 (message
                  "🐛 [pyvenv] Enhanced search result: %s"
                  (if (boundp 'pyvenv-virtual-env) pyvenv-virtual-env "FAILED")))))))))))

     ;; Fix interpreter path and update modeline
     (when
      pyvenv-remote-debug
      (message
       "🐛 [pyvenv] Final pyvenv-virtual-env check: %s"
       (if (boundp 'pyvenv-virtual-env) pyvenv-virtual-env "UNBOUND")))
     (when
      pyvenv-virtual-env
      (when
       pyvenv-remote-debug (message "🐛 [pyvenv] About to fix interpreter and update modeline"))
      (fix-remote-python-interpreter) (pyvenv-update-modeline))
     (when
      (not pyvenv-virtual-env)
      (when
       pyvenv-remote-debug
       (message "🐛 [pyvenv] WARNING: No virtual environment found in remote mode!"))))

   ;; Local file: normal activation
   (progn
    (when pyvenv-remote-debug (message "🐛 [pyvenv] LOCAL MODE: calling pyvenv-auto-activate"))
    (when
     (fboundp 'pyvenv-auto-activate) (pyvenv-auto-activate)
     (when
      pyvenv-remote-debug
      (message
       "🐛 [pyvenv] Local mode result: %s"
       (if (boundp 'pyvenv-virtual-env) pyvenv-virtual-env "UNBOUND"))))))

  (when pyvenv-remote-debug (message "🐛 [pyvenv] ========== ACTIVATION COMPLETE ==========")))

 (defun
  fix-remote-python-interpreter
  ()
  "Convert remote Python interpreter to local path."
  (when pyvenv-remote-debug (message "🐛 [pyvenv] === FIX-REMOTE-PYTHON-INTERPRETER ==="))
  (when
   pyvenv-remote-debug
   (message "🐛 [pyvenv] python-shell-interpreter bound?: %s" (boundp 'python-shell-interpreter)))
  (when
   pyvenv-remote-debug
   (message
    "🐛 [pyvenv] python-shell-interpreter value: %s"
    (if (boundp 'python-shell-interpreter) python-shell-interpreter "UNBOUND")))
  (when
   (and
    (boundp 'python-shell-interpreter)
    python-shell-interpreter
    (file-remote-p python-shell-interpreter))
   (let ((local-interpreter (file-local-name python-shell-interpreter)))
     (when
      pyvenv-remote-debug
      (message
       "🐛 [pyvenv] Converting remote interpreter: %s -> %s"
       python-shell-interpreter
       local-interpreter))
     (setq-local python-shell-interpreter local-interpreter)
     (when
      pyvenv-remote-debug
      (message
       "🐛 [pyvenv] python-shell-interpreter after conversion: %s" python-shell-interpreter))))
  (when pyvenv-remote-debug (message "🐛 [pyvenv] === FIX-REMOTE-PYTHON-INTERPRETER DONE ===")))

 (defun
  pyvenv-update-modeline
  ()
  "Update modeline with project info after venv activation."
  (when pyvenv-remote-debug (message "🐛 [pyvenv] === UPDATE-PYTHON-MODELINE ==="))
  (when
   pyvenv-remote-debug
   (message
    "🐛 [pyvenv] pyvenv-virtual-env: %s"
    (if (boundp 'pyvenv-virtual-env) pyvenv-virtual-env "UNBOUND")))
  (when
   pyvenv-remote-debug
   (message
    "🐛 [pyvenv] pyvenv-current-project-name bound?: %s" (boundp 'pyvenv-current-project-name)))
  (when
   pyvenv-virtual-env
   (let* ((venv-parent-dir (file-name-directory (directory-file-name pyvenv-virtual-env)))
          (project-name (file-name-nondirectory (directory-file-name venv-parent-dir))))
     (when pyvenv-remote-debug (message "🐛 [pyvenv] Calculated project name: %s" project-name))
     (when pyvenv-remote-debug (message "🐛 [pyvenv] venv-parent-dir: %s" venv-parent-dir))
     (setq pyvenv-current-project-name project-name)
     (setq-default pyvenv-current-project-name project-name)
     (when
      pyvenv-remote-debug
      (message
       "🐛 [pyvenv] pyvenv-current-project-name after setting: %s" pyvenv-current-project-name))
     (when
      pyvenv-remote-debug
      (message
       "🐛 [pyvenv] default pyvenv-current-project-name: %s"
       (default-value 'pyvenv-current-project-name)))
     (force-mode-line-update t)
     (when pyvenv-remote-debug (message "🐛 [pyvenv] Called force-mode-line-update"))))
  (when
   (not pyvenv-virtual-env)
   (when
    pyvenv-remote-debug
    (message "🐛 [pyvenv] WARNING: pyvenv-virtual-env is nil, cannot update modeline")))
  (when pyvenv-remote-debug (message "🐛 [pyvenv] === UPDATE-PYTHON-MODELINE DONE ===")))

 (defun
  safe-pyvenv-post-activate
  ()
  "Safe post-activate hook for remote environments."
  (when pyvenv-remote-debug (message "🐛 [pyvenv] === SAFE-PYVENV-POST-ACTIVATE ==="))
  (when
   pyvenv-remote-debug
   (message
    "🐛 [pyvenv] pyvenv-virtual-env in post-activate: %s"
    (if (boundp 'pyvenv-virtual-env) pyvenv-virtual-env "UNBOUND")))
  (when
   pyvenv-virtual-env
   (when
    pyvenv-remote-debug
    (message "🐛 [pyvenv] Post-activate processing venv: %s" pyvenv-virtual-env))
   (fix-remote-python-interpreter) (pyvenv-update-modeline))
  (when
   (not pyvenv-virtual-env)
   (when
    pyvenv-remote-debug
    (message "🐛 [pyvenv] WARNING: Post-activate called but pyvenv-virtual-env is nil")))
  (when pyvenv-remote-debug (message "🐛 [pyvenv] === SAFE-PYVENV-POST-ACTIVATE DONE ===")))

 ;; Hook management
 (when (fboundp 'pyvenv-auto-activate) (remove-hook 'python-mode-hook #'pyvenv-auto-activate))
 (add-hook 'python-mode-hook #'smart-pyvenv-activate)

 (when
  (fboundp 'config-pyvenv-post-activate)
  (remove-hook 'pyvenv-post-activate-hooks #'config-pyvenv-post-activate))
 (add-hook 'pyvenv-post-activate-hooks #'safe-pyvenv-post-activate)

 (when pyvenv-remote-debug (message "🐛 [pyvenv] Hook management completed"))
 (when
  pyvenv-remote-debug
  (message "🐛 [pyvenv] pyvenv-auto-activate available?: %s" (fboundp 'pyvenv-auto-activate)))
 (when
  pyvenv-remote-debug
  (message
   "🐛 [pyvenv] pyvenv-current-project-name bound?: %s" (boundp 'pyvenv-current-project-name)))
 (message "🔧 Remote pyvenv TRAMP support loaded (DEBUG MODE ENABLED)"))

(provide 'pyvenv-remote)

;;; pyvenv-remote.el ends here
