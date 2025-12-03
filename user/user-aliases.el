;;; user-aliases.el --- Function Aliases and Shortcuts -*- lexical-binding: t -*-
;;; Commentary:
;;      Function aliases to improve usability and provide shortcuts
;;      for commonly used Emacs functions.

;;; Code:
(require 'core-utils)

;; Declare external functions to suppress byte-compiler warnings
(declare-function toggle-list-themes-window "themes-utils" ())

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defalias 'yes-or-no-p #'y-or-n-p)
(provide 'user-aliases)
;;; user-aliases.el ends here
