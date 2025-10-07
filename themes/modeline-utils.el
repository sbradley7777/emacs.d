;;; modeline-utils.el --- Modeline Utility Functions -*- lexical-binding: t -*-
;;; Commentary:
;;      Functions for modifying and updating the main modeline.
;;      This module consolidates all modeline-related variables and functions.
;;      Note: Buffer-specific modelines (treemacs, imenu-list) are configured in their respective modules.

(require 'python-constants)

(core-utils-with-load-timing
 "modeline-utils.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Python Virtual Environment Modeline Variables
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; These variables are buffer-local and used by the Python venv indicator in the modeline
 (defvar pyvenv-current-project-name nil "Current project status for modeline display.")

 (defvar
  pyvenv-current-version
  nil
  "Python version of the detected virtual environment for modeline display.")

 ;; Make variables buffer-local so each buffer can show its own status
 (make-variable-buffer-local 'pyvenv-current-project-name)
 (make-variable-buffer-local 'pyvenv-current-version)

 ;; Set default values
 (setq-default pyvenv-current-project-name nil)
 (setq-default pyvenv-current-version nil)

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Modeline Update Functions
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (defun
  pyvenv-update-modeline () "Update modeline based on whether current file is in detected project."
  (let ((is-in-project
         (and
          pyvenv-project-root
          (string-prefix-p
           (pyvenv-normalize-path pyvenv-project-root)
           (pyvenv-normalize-path default-directory)))))
    (setq-local pyvenv-current-project-name (if is-in-project pyvenv-project-name "inactive"))
    (setq-local
     pyvenv-current-version (if is-in-project (default-value 'pyvenv-current-version) nil))
    (force-mode-line-update)))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Modeline Indicator Registration Functions
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (defun
  modeline-add-python-venv-indicator ()
  "Add Python virtual environment indicator to modeline.
Displays project name and Python version when a venv is active."
  (add-to-list
   'mode-line-misc-info
   '(:eval
     (when
      (and
       (local-variable-p 'pyvenv-current-project-name)
       pyvenv-current-project-name
       (not (string= pyvenv-current-project-name "inactive")))
      (propertize
       (concat
        "[venv: " pyvenv-current-project-name
        (when pyvenv-current-version (concat " (py" pyvenv-current-version ")")) "] ")
       'face
       (when
        (and
         (boundp 'pyvenv-modeline-color) pyvenv-modeline-color)
        `(:foreground ,pyvenv-modeline-color)))))))

 (defun
  modeline-add-system-info-indicator ()
  "Add username and hostname to modeline.
TRAMP-aware: shows remote hostname when editing remote files."
  (add-to-list
   'mode-line-misc-info
   '(:eval
     (concat
      "[" (user-login-name) "@" (or (file-remote-p default-directory 'host) (system-name)) "] "))))

 (provide 'modeline-utils))

;;; modeline-utils.el ends here
