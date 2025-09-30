;;; bash-config.el --- Bash/Shell Script Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Enhanced configuration for bash and shell script editing.

(require 'core-constants)
(require 'core-utils)

(core-utils-with-load-timing
 "bash-config.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Shell Script Mode Configuration
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;; Basic indentation settings - 4 spaces to match glocktopography.sh style
 (setq sh-basic-offset 4) ; 4-space indentation
 (setq sh-indentation 4) ; Consistent with basic offset

 ;; Shell type detection and preferences
 (setq sh-shell-file "/bin/bash") ; Default shell for new scripts
 (setq sh-indent-supported-here t) ; Enable smart indentation

 ;; Auto-detect shell type from shebang
 (add-to-list 'interpreter-mode-alist '("bash" . sh-mode))
 (add-to-list 'interpreter-mode-alist '("zsh" . sh-mode))
 (add-to-list 'interpreter-mode-alist '("fish" . sh-mode))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; File Associations
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;; Associate file extensions with sh-mode
 (add-to-list 'auto-mode-alist '("\\.sh\\'" . sh-mode))
 (add-to-list 'auto-mode-alist '("\\.bash\\'" . sh-mode))
 (add-to-list 'auto-mode-alist '("\\.zsh\\'" . sh-mode))
 (add-to-list 'auto-mode-alist '("\\.[^.]*rc\\'" . sh-mode)) ; .bashrc, .zshrc, etc.
 (add-to-list 'auto-mode-alist '("\\.env\\'" . sh-mode)) ; Environment files

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Enhanced Editing Features
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;; Enable electric characters for automatic pairing
 (add-hook 'sh-mode-hook 'electric-pair-local-mode)

 ;; Show matching parentheses
 (add-hook 'sh-mode-hook 'show-paren-mode)

 ;; Highlight current line
 (add-hook 'sh-mode-hook 'hl-line-mode)

 ;; Enable line numbers
 (add-hook 'sh-mode-hook 'display-line-numbers-mode)

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Syntax Highlighting Enhancements
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;; Custom font-lock keywords for better highlighting
 (defun
  enhance-bash-syntax-highlighting () "Add enhanced syntax highlighting for bash scripts."
  (font-lock-add-keywords
   nil
   '( ;; Highlight TODO/FIXME/NOTE comments
     ("\\<\\(TODO\\|FIXME\\|NOTE\\|HACK\\|BUG\\):" 1 font-lock-warning-face t)
     ;; Highlight common bash built-ins
     ("\\<\\(export\\|declare\\|local\\|readonly\\|unset\\)\\>" . font-lock-keyword-face)
     ;; Highlight file test operators
     ("\\(-[rwxfdeqntsSLbcpugkOGNh]\\)\\>" . font-lock-builtin-face))))

 (add-hook 'sh-mode-hook 'enhance-bash-syntax-highlighting)

 (core-message-success "Bash configuration loaded with 4-space indentation"))

(provide 'bash-config)
