;;; c-config.el --- C/C++ Language Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      C and C++ mode support and configuration.
;;      Supports both c-mode/c++-mode and c-ts-mode/c++-ts-mode with shared configuration.

;;; Code:
(require 'core-utils)
(require 'core-logging)
(require 'core-constants)
(require 'lang-utils)
(require 'flymake-lang-setup)
(require 'cc-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 c-setup-common
 ()
 "Common setup for both `c-mode' and c-ts-mode."
 (lang-setup-full 'c-basic-offset core-tab-width)
 (c-set-offset 'substatement-open 0)
 (lang-setup-flymake-backend-lsp))

(defun
 c++-setup-common
 ()
 "Common setup for both c++-mode and c++-ts-mode."
 (lang-setup-full 'c-basic-offset core-tab-width)
 (c-set-offset 'substatement-open 0)
 (c-set-offset 'innamespace 0)
 (lang-setup-flymake-backend-lsp))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; C/C++ Mode Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Use K&R style as base with modifications
(setq c-default-style '((java-mode . "java") (awk-mode . "awk") (other . "k&r")))

;; File associations (treesit-auto overrides when grammar available)
(lang-register-file-extensions 'c-mode "\\.c\\'" "\\.h\\'")
(lang-register-file-extensions
 'c++-mode "\\.cpp\\'" "\\.hpp\\'" "\\.cc\\'" "\\.hh\\'" "\\.cxx\\'" "\\.hxx\\'")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Mode Hooks - Apply to both regular and tree-sitter modes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(lang-register-dual-mode-hooks c c-setup-common)
(lang-register-dual-mode-hooks c++ c++-setup-common)

(core-message-lang-loaded "C/C++" "c-mode, c++-mode, c-ts-mode, c++-ts-mode")
(provide 'c-config)
;;; c-config.el ends here
