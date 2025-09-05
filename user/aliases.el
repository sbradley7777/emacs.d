;;; aliases.el --- Function Aliases and Shortcuts -*- lexical-binding: t -*-
;;; Commentary:
;;      Function aliases to improve usability and provide shortcuts
;;      for commonly used Emacs functions.

(require 'utils)

(with-load-timing
 "aliases.el"
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Interactive function aliases
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Use shorter y/n prompts instead of yes/no
 (defalias 'yes-or-no-p 'y-or-n-p)

 ;; Make this module available for loading with (require 'aliases)
 (provide 'aliases))
