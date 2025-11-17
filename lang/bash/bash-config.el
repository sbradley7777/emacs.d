;;; bash-config.el --- Bash/Shell Script Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Enhanced configuration for bash and shell script editing.
;;      Supports both sh-mode and bash-ts-mode with shared configuration.

;;; Code:
(require 'core-utils)
(require 'core-logging)
(require 'core-constants)
(require 'lang-utils)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Shared Configuration Function
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 bash-setup-common
 ()
 "Common setup for both sh-mode and bash-ts-mode."
 (lang-setup-full 'sh-basic-offset core-tab-width '((sh-indentation . core-tab-width))))

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
;; Syntax Highlighting Enhancements
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 enhance-bash-syntax-highlighting ()
 "Add enhanced syntax highlighting for bash scripts.
Only applies to sh-mode as bash-ts-mode uses tree-sitter highlighting."
 (unless
  (derived-mode-p 'bash-ts-mode)
  (font-lock-add-keywords
   nil
   '(("\\<\\(TODO\\|FIXME\\|NOTE\\|HACK\\|BUG\\):" 1 font-lock-warning-face t)
     ("\\<\\(export\\|declare\\|local\\|readonly\\|unset\\)\\>" . font-lock-keyword-face)
     ("\\(-[rwxfdeqntsSLbcpugkOGNh]\\)\\>" . font-lock-builtin-face)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Mode Hooks - Apply to both sh-mode and bash-ts-mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(lang-register-dual-mode-hooks sh bash-setup-common '(enhance-bash-syntax-highlighting))

(core-message-success
 "Bash configuration loaded with 4-space indentation (sh-mode and bash-ts-mode)")
(provide 'bash-config)
;;; bash-config.el ends here
