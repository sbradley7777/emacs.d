;;; core-config-loader.el --- Configuration Module Loading Infrastructure -*- lexical-binding: t -*-
;;; Commentary:
;;      Custom use-package keyword for tracking module load times and descriptions.
;;      Provides the :description keyword that integrates with init.el diagnostics.

;;; Code:
(require 'core-logging)

;; Declare external variables to suppress byte-compiler warnings
(defvar use-package-keywords) ; From use-package-core.el

;; Declare external functions to suppress byte-compiler warnings
(declare-function use-package-only-one "use-package-core" (label args f))
(declare-function use-package-error "use-package-core" (msg))
(declare-function use-package-process-keywords "use-package-core" (name plist &optional state))
(declare-function use-package-concat "use-package-core" (elems &optional after-each))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Custom use-package :description keyword
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 core-config-loader-normalize/:description
 (_name _keyword args)
 "Normalize :description keyword - just returns the description string."
 (use-package-only-one
  (symbol-name :description) args
  (lambda
   (_label arg)
   (cond
    ((stringp arg)
     arg)
    (t
     (use-package-error ":description expects a string"))))))
(defun
 core-config-loader-handler/:description
 (name _keyword description rest state)
 "Handle :description keyword to track module loading with timing."
 (let ((body (use-package-process-keywords name rest state)))
   (use-package-concat
    `((let ((load-time (current-time))
            (module-name ',name)
            (desc ,description))
        (condition-case err
            (progn
             ,@body
             (let ((elapsed (float-time (time-subtract (current-time) load-time))))
               (add-to-list 'config-load-results (list module-name 'success elapsed desc))
               (core-message-success "Loaded %s (%.3fs)" desc elapsed)))
          (error
           (let ((elapsed (float-time (time-subtract (current-time) load-time))))
             (add-to-list
              'config-load-results
              (list module-name 'failed elapsed desc (error-message-string err)))
             (core-message-error "Failed to load %s: %s" desc (error-message-string err))
             (signal (car err) (cdr err)))))))
    nil)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Keyword Registration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Register the custom keyword (before :ensure, so it wraps everything)
(setq
 use-package-keywords
 (let* ((pos (cl-position :preface use-package-keywords)))
   (if
    pos
    (append
     (cl-subseq use-package-keywords 0 (1+ pos))
     '(:description)
     (cl-subseq use-package-keywords (1+ pos)))
    (cons :description use-package-keywords))))

;; Set the handlers
(defalias 'use-package-normalize/:description 'core-config-loader-normalize/:description)
(defalias 'use-package-handler/:description 'core-config-loader-handler/:description)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Config Module Macro
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defmacro
 load-module (name &rest args)
 "Load a configuration module with automatic :ensure nil and :demand t.
NAME is the module name (symbol).
ARGS are additional use-package keywords like :after, :description, :config, etc."
 `(use-package ,name :ensure nil :demand t ,@args))

(core-message-config "Configuration loader with :description keyword and load-module macro ready")
(provide 'core-config-loader)
;;; core-config-loader.el ends here
