;;; c-config.el --- C/C++ Language Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      C and C++ mode support and configuration.
;;      Supports both c-mode/c++-mode and c-ts-mode/c++-ts-mode with shared configuration.

(require 'core-utils)
(require 'core-logging)
(require 'core-constants)
(require 'lang-utils)
(require 'cc-mode)

(core-utils-with-load-timing
 "c-config.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Shared Configuration Function
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (defun
  c-setup-common
  ()
  "Common setup for both c-mode and c-ts-mode."
  (lang-setup-full 'c-basic-offset core-tab-width)
  (c-set-offset 'substatement-open 0))

 (defun
  c++-setup-common
  ()
  "Common setup for both c++-mode and c++-ts-mode."
  (lang-setup-full 'c-basic-offset core-tab-width)
  (c-set-offset 'substatement-open 0)
  (c-set-offset 'innamespace 0))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; C/C++ Mode Configuration
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;; Use K&R style as base with modifications
 (setq c-default-style '((java-mode . "java") (awk-mode . "awk") (other . "k&r")))

 ;; File associations (treesit-auto overrides when grammar available)
 (add-to-list 'auto-mode-alist '("\\.c\\'" . c-mode))
 (add-to-list 'auto-mode-alist '("\\.h\\'" . c-mode))
 (add-to-list 'auto-mode-alist '("\\.cpp\\'" . c++-mode))
 (add-to-list 'auto-mode-alist '("\\.hpp\\'" . c++-mode))
 (add-to-list 'auto-mode-alist '("\\.cc\\'" . c++-mode))
 (add-to-list 'auto-mode-alist '("\\.hh\\'" . c++-mode))
 (add-to-list 'auto-mode-alist '("\\.cxx\\'" . c++-mode))
 (add-to-list 'auto-mode-alist '("\\.hxx\\'" . c++-mode))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Mode Hooks - Apply to both regular and tree-sitter modes
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (lang-register-dual-mode-hooks c c-setup-common)
 (lang-register-dual-mode-hooks c++ c++-setup-common)

 (core-message-success "C/C++ configuration loaded (c-mode, c++-mode, c-ts-mode, c++-ts-mode)"))

(provide 'c-config)

;;; c-config.el ends here
