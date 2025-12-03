;;; user-aliases.el --- Function Aliases and Shortcuts -*- lexical-binding: t -*-
;;; Commentary:
;;      Function aliases to improve usability and provide shortcuts
;;      for commonly used Emacs functions.

;;; Code:
(require 'core-utils)

;; Declare external functions to suppress byte-compiler warnings
(declare-function theme-utils-list-themes "theme-utils" ())
(declare-function theme-utils-switch-theme "theme-utils" (theme-name))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defalias 'yes-or-no-p #'y-or-n-p)
(defalias 'toggle-list-themes-window #'theme-utils-list-themes)
(defalias 'switch-theme #'theme-utils-switch-theme)
(provide 'user-aliases)
;;; user-aliases.el ends here
