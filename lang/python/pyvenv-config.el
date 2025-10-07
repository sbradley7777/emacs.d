;;; pyvenv-config.el --- Auto-detect Once Python Virtual Environment Management -*- lexical-binding: t -*-
;;; Commentary:
;;      AUTO-DETECT ONCE APPROACH: Automatically detects the first Python virtual
;;      environment encountered and remembers it as THE project. The virtual
;;      environment is activated and pyvenv's default modeline indicator shows
;;      the venv name.

(require 'python-constants)
(require 'pyvenv-utils)

(core-utils-with-load-timing
 "pyvenv-config.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Auto-detect Once Virtual Environment Support
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;; Auto-detect once and activate
 (defun
  pyvenv-auto-activate () "Auto-detect virtual environment once and activate it." (interactive)
  (unless
   pyvenv-project-root
   ;; First time - auto-detect project
   (core-message-info "Auto-detecting Python virtual environment...")
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
         (core-message-success "Activated Python venv for project: %s" pyvenv-project-name)

         ;; Update Python shell interpreter
         (let ((venv-python (expand-file-name "bin/python" detected-venv)))
           (when (file-executable-p venv-python) (setq python-shell-interpreter venv-python))))
        (core-message-warning "Warning: pyvenv-activate function not available")))
      (core-message-warning "No Python virtual environment found")))))

 ;; Initialize pyvenv
 (if
  (fboundp 'use-package) (use-package pyvenv :config (pyvenv-mode 1))
  ;; Fallback when use-package is not available
  (when (require 'pyvenv nil t) (pyvenv-mode 1)))

 ;; Auto-activate when opening Python files
 (add-hook 'python-mode-hook #'pyvenv-auto-activate))

(provide 'pyvenv-config)

;;; pyvenv-config.el ends here
