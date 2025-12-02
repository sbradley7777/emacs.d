;;; git-constants.el --- Git Configuration Constants -*- lexical-binding: t -*-
;;; Commentary:
;;      Centralized constants for git configuration modules.

;;; Code:
(require 'core-utils)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defconst
 git-magit-format-fill-margin
 2
 "Margin offset subtracted from `fill-column' when formatting Magit buffer lines.")
(defconst git-magit-log-commit-count 30 "Number of commits to display in Magit log sections.")
(provide 'git-constants)
;;; git-constants.el ends here
