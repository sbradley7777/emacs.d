;;; bash-config.el --- Bash/Shell Script Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Enhanced configuration for bash and shell script editing.
;;      Supports both sh-mode and bash-ts-mode with shared configuration.

(require 'core-utils)
(require 'core-logging)
(require 'core-constants)

(core-utils-with-load-timing
 "bash-config.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Shared Configuration Function
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (defun
  bash-setup-common
  ()
  "Common setup for both sh-mode and bash-ts-mode."
  (setq indent-tabs-mode nil)
  (setq sh-basic-offset core-tab-width)
  (setq sh-indentation core-tab-width)
  (electric-indent-mode 1)
  (electric-pair-local-mode 1)
  (show-paren-mode 1)
  (hl-line-mode 1)
  (display-line-numbers-mode 1))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Shell Script Mode Configuration
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;; Shell type detection and preferences
 (setq sh-shell-file "/bin/bash")
 (setq sh-indent-supported-here t)

 ;; Auto-detect shell type from shebang
 (add-to-list 'interpreter-mode-alist '("bash" . sh-mode))
 (add-to-list 'interpreter-mode-alist '("zsh" . sh-mode))
 (add-to-list 'interpreter-mode-alist '("fish" . sh-mode))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; File Associations
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;; Associate file extensions with sh-mode (treesit-auto will override when bash grammar available)
 (add-to-list 'auto-mode-alist '("\\.sh\\'" . sh-mode))
 (add-to-list 'auto-mode-alist '("\\.bash\\'" . sh-mode))
 (add-to-list 'auto-mode-alist '("\\.zsh\\'" . sh-mode))
 (add-to-list 'auto-mode-alist '("\\.[^.]*rc\\'" . sh-mode))
 (add-to-list 'auto-mode-alist '("\\.env\\'" . sh-mode))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Syntax Highlighting Enhancements
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Mode Hooks - Apply to both sh-mode and bash-ts-mode
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;; Apply common setup to sh-mode
 (add-hook 'sh-mode-hook 'bash-setup-common)
 (add-hook 'sh-mode-hook 'enhance-bash-syntax-highlighting)

 ;; Apply common setup to bash-ts-mode (when tree-sitter grammar available)
 (add-hook 'bash-ts-mode-hook 'bash-setup-common)
 (add-hook 'bash-ts-mode-hook 'enhance-bash-syntax-highlighting)

 (core-message-success
  "Bash configuration loaded with 4-space indentation (sh-mode and bash-ts-mode)"))

(provide 'bash-config)
