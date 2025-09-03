;;; aliases.el --- Function Aliases and Shortcuts -*- lexical-binding: t -*-
;;; Commentary:
;;      Function aliases to improve usability and provide shortcuts
;;      for commonly used Emacs functions.

(defvar config-load-start-time (current-time))
(message "🔄  Loading aliases.el...")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Interactive function aliases
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Use shorter y/n prompts instead of yes/no
(defalias 'yes-or-no-p 'y-or-n-p)

;; Make this module available for loading with (require 'aliases)
(provide 'aliases)
(message
 "aliases.el loaded (%.2fs)" (float-time (time-subtract (current-time) config-load-start-time)))
