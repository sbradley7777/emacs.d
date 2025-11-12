;;; lang-utils.el --- Language Mode Configuration Utilities -*- lexical-binding: t -*-
;;; Commentary:
;;      Shared utilities for language mode configuration.
;;      Provides common setup functions and hook registration for both
;;      regular and tree-sitter language modes.

;;; Code:
(require 'core-utils)
(require 'core-logging)
(core-utils-with-load-timing
 "lang-utils.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Common Mode Setup Functions
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  lang-setup-basic-editing ()
  "Apply basic editing settings common to all language modes.
These settings are applied before language-specific configuration."
  (electric-indent-mode 1) (setq indent-tabs-mode nil))
 (defun
  lang-setup-ui-enhancements
  ()
  "Apply UI enhancements for programming modes."
  (electric-pair-local-mode 1)
  (show-paren-mode 1)
  (hl-line-mode 1)
  (display-line-numbers-mode 1))
 (defun
  lang-apply-indent-settings
  (indent-var indent-value &optional extra-vars)
  "Set INDENT-VAR to INDENT-VALUE and optionally apply EXTRA-VARS.
EXTRA-VARS should be an alist of (variable . value) pairs."
  (set indent-var indent-value)
  (when extra-vars (dolist (var-pair extra-vars) (set (car var-pair) (cdr var-pair)))))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; File Extension Registration
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  lang-register-file-extensions (mode &rest patterns)
  "Register file PATTERNS to activate MODE.
MODE is the major mode to activate (e.g., 'c-mode, 'sh-mode).
PATTERNS are regex patterns for matching filenames (e.g., \"\\\\.c\\\\'\" \"\\\\.h\\\\'\").

Example:
  (lang-register-file-extensions 'c-mode \"\\\\.c\\\\'\" \"\\\\.h\\\\'\")
  (lang-register-file-extensions 'sh-mode \"\\\\.sh\\\\'\" \"\\\\.bash\\\\'\" \"\\\\.zsh\\\\'\")"
  (dolist (pattern patterns) (add-to-list 'auto-mode-alist (cons pattern mode))))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Mode Hook Registration
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defmacro
  lang-register-dual-mode-hooks (lang-name setup-function &optional extra-hooks)
  "Register SETUP-FUNCTION for both regular and tree-sitter modes of LANG-NAME.
LANG-NAME should be a symbol like 'python or 'bash.
EXTRA-HOOKS is an optional list of additional hook functions to register."
  (let ((base-mode-hook (intern (format "%s-mode-hook" lang-name)))
        (ts-mode-hook (intern (format "%s-ts-mode-hook" lang-name))))
    `(progn
      ;; Register main setup function for both modes
      (add-hook ',base-mode-hook ',setup-function) (add-hook ',ts-mode-hook ',setup-function)
      ;; Register any additional hooks
      ,@
      (when
       extra-hooks
       (mapcar
        (lambda
         (hook-fn)
         `(progn (add-hook ',base-mode-hook ',hook-fn) (add-hook ',ts-mode-hook ',hook-fn)))
        extra-hooks)))))
 (defun
  lang-add-dual-mode-hooks (base-mode-hook ts-mode-hook hook-function)
  "Add HOOK-FUNCTION to both BASE-MODE-HOOK and TS-MODE-HOOK.
This is a simpler alternative to lang-register-dual-mode-hooks that accepts
explicit hook names instead of inferring them from a language name.

Example:
  (lang-add-dual-mode-hooks 'python-mode-hook 'python-ts-mode-hook #'my-setup-function)
  (lang-add-dual-mode-hooks 'js-json-mode-hook 'json-ts-mode-hook #'json-setup-common)"
  (add-hook base-mode-hook hook-function) (add-hook ts-mode-hook hook-function))
 (defun
  lang-remove-dual-mode-hooks (base-mode-hook ts-mode-hook hook-function)
  "Remove HOOK-FUNCTION from both BASE-MODE-HOOK and TS-MODE-HOOK.
Counterpart to lang-add-dual-mode-hooks for removing hooks from dual modes.

Example:
  (lang-remove-dual-mode-hooks 'python-mode-hook 'python-ts-mode-hook #'pyvenv-auto-activate)"
  (remove-hook base-mode-hook hook-function) (remove-hook ts-mode-hook hook-function))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Composite Setup Functions
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  lang-setup-minimal
  (indent-var indent-value &optional extra-indent-vars)
  "Minimal language setup: basic editing + indentation.
Sets INDENT-VAR to INDENT-VALUE and applies EXTRA-INDENT-VARS if provided.
Use for simple file formats (JSON, YAML, etc.)."
  (lang-setup-basic-editing)
  (lang-apply-indent-settings indent-var indent-value extra-indent-vars))
 (defun
  lang-setup-full
  (indent-var indent-value &optional extra-indent-vars)
  "Full language setup: basic editing + UI enhancements + indentation.
Sets INDENT-VAR to INDENT-VALUE and applies EXTRA-INDENT-VARS if provided.
Use for programming languages (Python, C, Bash, etc.)."
  (lang-setup-basic-editing)
  (lang-setup-ui-enhancements)
  (lang-apply-indent-settings indent-var indent-value extra-indent-vars)))
(provide 'lang-utils)
;;; lang-utils.el ends here
