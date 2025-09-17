;;; pyvenv-config.el --- Auto-detect Once Python Virtual Environment Management -*- lexical-binding: t -*-
;;; Commentary:
;;      AUTO-DETECT ONCE APPROACH: Automatically detects the first Python virtual
;;      environment encountered and remembers it as THE project. Subsequent files
;;      are checked against this detected project:
;;      - Files IN the project → show project name in modeline
;;      - Files OUTSIDE the project → show "inactive" in modeline
;;
;;      The virtual environment stays globally active (following pyvenv's design)
;;      but the modeline reflects whether the current file is part of the project.

(require 'core-utils)
(require 'python-constants)
(require 'pyvenv-utils)

(with-load-timing
 "pyvenv-config.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Auto-detect Once Virtual Environment Support
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;; Auto-detect once and activate
 (defun
  pyvenv-auto-activate
  ()
  "Auto-detect virtual environment once, then update modeline based on file location."
  (interactive)
  (if
   pyvenv-project-root
   ;; Project already detected - just update modeline
   (pyvenv-update-modeline)
   ;; First time - auto-detect project
   (message "🚀 Auto-detecting Python virtual environment...")
   (let ((detected-venv (pyvenv-find-venv)))
     (if
      detected-venv
      (progn
       ;; Store detected project info
       (setq
        pyvenv-project-root
        (file-name-directory (directory-file-name detected-venv))
        pyvenv-project-name
        (file-name-nondirectory (directory-file-name pyvenv-project-root)))

       ;; Activate the virtual environment
       (if
        (fboundp 'pyvenv-activate)
        (progn
         (pyvenv-activate detected-venv)
         (message "✅ Activated Python venv for project: %s" pyvenv-project-name)

         ;; Get Python version and store globally, then update modeline
         (setq pyvenv-current-version (pyvenv-get-python-version detected-venv))
         (setq-default pyvenv-current-version pyvenv-current-version)
         (pyvenv-update-modeline)

         ;; Update Python shell interpreter
         (let ((venv-python (expand-file-name "bin/python" detected-venv)))
           (when (file-executable-p venv-python) (setq python-shell-interpreter venv-python))))
        (message "⚠️  Warning: pyvenv-activate function not available")))
      (progn (message "❌ No Python virtual environment found") (pyvenv-update-modeline))))))

 ;; Disable pyvenv modeline completely - we handle it ourselves via hooks
 (setq pyvenv-mode-line-indicator nil)

 ;; Initialize pyvenv
 (if
  (fboundp 'use-package) (use-package pyvenv :config (pyvenv-mode 1))
  ;; Fallback when use-package is not available
  (when (require 'pyvenv nil t) (pyvenv-mode 1)))

 ;; Auto-activate when opening Python files
 (add-hook 'python-mode-hook #'pyvenv-auto-activate)

 ;; Make this module available for loading
 (provide 'pyvenv-config))

;;; pyvenv-config.el ends here
