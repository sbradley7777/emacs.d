;;; user-aliases.el --- Function Aliases and Shortcuts -*- lexical-binding: t -*-
;;; Commentary:
;;      Function aliases to improve usability and provide shortcuts
;;      for commonly used Emacs functions.

(require 'core-utils)

(core-utils-with-load-timing
 "user-aliases.el"
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Interactive function aliases
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Use shorter y/n prompts instead of yes/no
 (defalias 'yes-or-no-p 'y-or-n-p)
 (defalias 'list-themes 'theme-utils-list-themes)
 (defalias 'switch-theme 'theme-utils-switch-theme))

(provide 'user-aliases)
