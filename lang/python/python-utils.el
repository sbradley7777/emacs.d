;;; python-utils.el --- Python Utility Functions -*- lexical-binding: t -*-
;;; Commentary:
;;      General utility functions for Python development support,
;;      including both local and remote contexts.

(require 'core-utils)
(require 'python-constants)

(with-load-timing
 "python-utils.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Python Executable Detection
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (defun
  eglot-find-pylsp () "Find pylsp executable for current context (local or remote)."
  (if
   (file-remote-p default-directory)
   ;; Remote: check if pylsp exists via TRAMP
   (progn
    (require 'tramp-utils)
    (if
     (eglot-remote-find-pylsp) (progn (message "✅ EGLOT: Found pylsp on remote") (list "pylsp"))
     (progn
      (message "⚠️ EGLOT: pylsp not found on remote, using program name anyway") (list "pylsp"))))
   ;; Local: check PATH first, then fallback to full path
   (if
    (executable-find "pylsp")
    (progn (message "✅ EGLOT: Found pylsp in PATH for local") (list "pylsp"))
    (progn
     (message "⚠️ EGLOT: Using fallback pylsp path for local: %s" eglot-pylsp-path)
     (list eglot-pylsp-path))))))

;; Make this module available for loading
(provide 'python-utils)
;;; python-utils.el ends here
