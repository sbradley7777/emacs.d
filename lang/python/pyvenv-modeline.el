;;; pyvenv-modeline.el --- Custom clickable Python venv modeline indicator -*- lexical-binding: t -*-
;;; Commentary:
;;      Provides a custom clickable Python virtual environment indicator for doom-modeline.
;;      Shows a Python icon when a venv is active and displays project info when clicked.
(require 'core-utils)
(require 'python-constants)
(require 'pyvenv-utils)
(require 'core-logging)
(core-utils-with-load-timing
 "pyvenv-modeline.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Helper Functions
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  pyvenv-modeline-file-in-project-p
  ()
  "Check if current buffer's file is under the pyvenv project root."
  (and
   (boundp 'pyvenv-project-root) pyvenv-project-root buffer-file-name
   (string-prefix-p (expand-file-name pyvenv-project-root) (expand-file-name buffer-file-name))))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Clickable Python Venv Indicator
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  pyvenv-modeline-show-info
  ()
  "Display Python virtual environment info in minibuffer when clicked."
  (interactive)
  (if
   (and (boundp 'pyvenv-virtual-env) pyvenv-virtual-env)
   (let* ((project-name (if (boundp 'pyvenv-project-name) pyvenv-project-name "Unknown"))
          (venv-path pyvenv-virtual-env)
          (python-bin (expand-file-name "bin/python" pyvenv-virtual-env))
          (python-version (pyvenv-get-version-from-executable python-bin)))
     (core-message-info
      "Python Project: %s | Venv: %s | Version: %s"
      project-name
      (abbreviate-file-name venv-path)
      (or python-version "Unknown")))
   (core-message-warning "No Python virtual environment active")))
 (defun
  pyvenv-modeline-indicator () "Return modeline indicator for Python venv with click handler."
  (when
   (and (boundp 'pyvenv-virtual-env) pyvenv-virtual-env (pyvenv-modeline-file-in-project-p))
   (let* ((venv-name (file-name-nondirectory (directory-file-name pyvenv-virtual-env)))
          (indicator (format " 🐍 %s " venv-name)))
     (propertize
      indicator
      'face
      'font-lock-constant-face
      'help-echo
      "Click to show Python venv info"
      'mouse-face
      'mode-line-highlight
      'local-map
      (let ((map (make-sparse-keymap)))
        (define-key map [mode-line mouse-1] #'pyvenv-modeline-show-info)
        map)))))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; doom-modeline Integration (if doom-modeline is available)
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (with-eval-after-load
  'doom-modeline
  (doom-modeline-def-segment
   pyvenv-indicator "Display Python virtual environment with clickable icon."
   (when
    (and (boundp 'pyvenv-virtual-env) pyvenv-virtual-env (pyvenv-modeline-file-in-project-p))
    (let ((icon
           (doom-modeline-icon
            'mdicon
            "nf-md-language_python"
            "🐍"
            " "
            :face 'doom-modeline-lsp-success)))
      (propertize
       icon 'help-echo "Click to show Python venv info" 'mouse-face 'mode-line-highlight 'local-map
       (let ((map (make-sparse-keymap)))
         (define-key map [mode-line mouse-1] #'pyvenv-modeline-show-info)
         map)))))

  (core-message-success "Python venv modeline segment loaded"))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Fallback for Default Emacs Modeline
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; If not using doom-modeline, add to global-mode-string
 (unless
  (featurep 'doom-modeline)
  (add-hook
   'pyvenv-post-activate-hooks
   (lambda
    ()
    (setq-default
     global-mode-string (append global-mode-string (list '(:eval (pyvenv-modeline-indicator)))))))
  (add-hook 'pyvenv-post-deactivate-hooks (lambda () (setq-default global-mode-string nil)))))
(provide 'pyvenv-modeline)
;;; pyvenv-modeline.el ends here
