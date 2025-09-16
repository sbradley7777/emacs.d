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
   config-python-detected-project-root
   ;; Project already detected - just update modeline
   (update-python-modeline)
   ;; First time - auto-detect project
   (message "🚀 Auto-detecting Python virtual environment...")
   (let ((detected-venv (find-venv-in-parents)))
     (if
      detected-venv
      (progn
       ;; Store detected project info
       (setq
        config-python-detected-project-root
        (file-name-directory (directory-file-name detected-venv))
        config-python-detected-project-name
        (file-name-nondirectory (directory-file-name config-python-detected-project-root)))

       ;; Activate the virtual environment
       (if
        (fboundp 'pyvenv-activate)
        (progn
         (pyvenv-activate detected-venv)
         (message "✅ Activated Python venv for project: %s" config-python-detected-project-name)

         ;; Get Python version and store globally, then update modeline
         (setq config-python-version (config-get-python-version detected-venv))
         (setq-default config-python-version config-python-version)
         (update-python-modeline)

         ;; Update Python shell interpreter
         (let ((venv-python (expand-file-name "bin/python" detected-venv)))
           (when (file-executable-p venv-python) (setq python-shell-interpreter venv-python))))
        (message "⚠️  Warning: pyvenv-activate function not available")))
      (progn (message "❌ No Python virtual environment found") (update-python-modeline))))))

 ;; Configure pyvenv modeline
 (setq
  pyvenv-mode-line-indicator
  '(config-python-project-name
    ("[venv: "
     config-python-project-name
     (config-python-version (" (py" config-python-version ")"))
     "] ")))

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
