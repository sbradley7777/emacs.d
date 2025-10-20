;;; tree-sitter-constants.el --- Tree-sitter Configuration Constants -*- lexical-binding: t -*-
;;; Commentary:
;;      Constants for tree-sitter grammar management and configuration.
;;      Defines paths and settings used across tree-sitter modules.

(require 'core-constants)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Tree-sitter Directory Constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defconst
 core-treesit-grammar-dir (expand-file-name "tree-sitter/" emacs-local-dir)
 "Directory for tree-sitter grammar installations.
Uses emacs-local-dir constant (~/.emacs.d/local/tree-sitter/).")

(provide 'tree-sitter-constants)

;;; tree-sitter-constants.el ends here
