;;; bash-config.el --- Bash/Shell Script Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Enhanced configuration for bash and shell script editing.
;;      Supports both sh-mode and bash-ts-mode with shared configuration.

;;; Code:
(require 'core-utils)
(require 'core-logging)
(require 'core-constants)
(require 'lang-utils)
(require 'flymake-lang-setup)

;; External declarations
(declare-function flymake-shellcheck-load "flymake-shellcheck")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 bash-setup-common
 ()
 "Common setup for both `sh-mode' and bash-ts-mode."
 (lang-setup-full 'sh-basic-offset core-tab-width '((sh-indentation . core-tab-width)))
 (lang-setup-flymake-backend-package "shellcheck" 'flymake-shellcheck-load))

(defun
 enhance-bash-syntax-highlighting ()
 "Add enhanced syntax highlighting for bash scripts.
Only applies to `sh-mode' as bash-ts-mode uses tree-sitter highlighting."
 (unless
  (derived-mode-p 'bash-ts-mode)
  (font-lock-add-keywords
   nil
   '(("\\<\\(TODO\\|FIXME\\|NOTE\\|HACK\\|BUG\\):" 1 font-lock-warning-face t)
     ("\\<\\(export\\|declare\\|local\\|readonly\\|unset\\)\\>" . font-lock-keyword-face)
     ("\\(-[rwxfdeqntsSLbcpugkOGNh]\\)\\>" . font-lock-builtin-face)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Shell Script Mode Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Shell type detection and preferences
(setq sh-shell-file "/bin/bash")
(setq sh-indent-supported-here t)

;; Auto-detect shell type from shebang
(add-to-list 'interpreter-mode-alist '("bash" . sh-mode))
(add-to-list 'interpreter-mode-alist '("zsh" . sh-mode))
(add-to-list 'interpreter-mode-alist '("fish" . sh-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; File Associations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; File associations (treesit-auto overrides when grammar available)
(lang-register-file-extensions
 'sh-mode "\\.sh\\'" "\\.bash\\'" "\\.zsh\\'" "\\.[^.]*rc\\'" "\\.env\\'")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Use flymake-shellcheck package instead of built-in sh-shellcheck-flymake
;; The built-in version in Emacs 30 has issues with bash-ts-mode and JSON parsing
(use-package
 flymake-shellcheck
 :ensure t
 :config (core-message-config "Flymake shellcheck integration configured"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; LSP Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Configure bash-language-server
;; NOTE: bash-language-server v5.6.0 appears broken (produces no LSP output)
;; Commented out until fixed - using flymake-shellcheck instead
;; Remove bash modes from eglot-server-programs to prevent Eglot from trying to start
(with-eval-after-load
 'eglot
 (setq eglot-server-programs (assq-delete-all 'sh-mode eglot-server-programs))
 (setq eglot-server-programs (assq-delete-all 'bash-ts-mode eglot-server-programs)))
;; (with-eval-after-load
;;  'eglot
;;  ;; Explicitly add bash-language-server to eglot-server-programs
;;  (add-to-list
;;   'eglot-server-programs '((sh-mode bash-ts-mode sh-ts-mode) . ("bash-language-server" "start")))
;;  ;; Configure shellcheck path
;;  (add-to-list 'eglot-workspace-configuration '(:bashIde (:shellcheckPath "shellcheck"))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Mode Hooks - Apply to sh-mode, sh-ts-mode, and bash-ts-mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(lang-register-dual-mode-hooks sh bash-setup-common)
(add-hook 'bash-ts-mode-hook 'bash-setup-common)
(add-hook 'sh-mode-hook 'enhance-bash-syntax-highlighting)
(add-hook 'sh-ts-mode-hook 'enhance-bash-syntax-highlighting)
(add-hook 'bash-ts-mode-hook 'enhance-bash-syntax-highlighting)

(core-message-success
 "Bash configuration loaded (sh-mode and bash-ts-mode with flymake-shellcheck)")
(provide 'bash-config)
;;; bash-config.el ends here
