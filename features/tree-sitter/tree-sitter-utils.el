;;; tree-sitter-utils.el --- Tree-sitter Utility Functions -*- lexical-binding: t -*-
;;; Commentary:
;;      Utility functions for working with tree-sitter grammars and functionality.
;;      Provides helpers for grammar management, counting, and availability checks.
(require 'core-constants)
(require 'core-utils)
(require 'tree-sitter-constants)
(core-utils-with-load-timing
 "tree-sitter-utils.el"
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Grammar Management
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  treesit-utils-get-installed-grammars ()
  "Get list of installed tree-sitter grammars with details.
Returns a list of plists with :name and :file keys."
  (if
   (not (and (fboundp 'treesit-available-p) (treesit-available-p))) '()
   (let ((grammars '())
         (pattern "libtree-sitter-\\([^.]+\\)\\.\\(so\\|dylib\\)$")
         (transform-fn (lambda (file lang-name _ext) (list :name lang-name :file file))))
     ;; Scan the primary grammar directory
     (when-let ((results
                 (core-utils-scan-directory-for-pattern
                  features-treesit-grammar-dir pattern transform-fn)))
       (setq grammars (append grammars results)))
     ;; Also check treesit-extra-load-path if it's set
     (when
      (boundp 'treesit-extra-load-path)
      (dolist
       (dir treesit-extra-load-path)
       (when
        (and dir (file-directory-p dir) (not (string= dir features-treesit-grammar-dir)))
        (when-let ((results (core-utils-scan-directory-for-pattern dir pattern transform-fn)))
          (setq grammars (append grammars results))))))
     grammars)))

 (defun
  treesit-utils-count-installed-grammars ()
  "Count the number of installed tree-sitter grammars.
Returns the count of .so/.dylib grammar files found in the tree-sitter grammar directory."
  (length (treesit-utils-get-installed-grammars)))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Mode Name Parsing
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  treesit-utils-is-ts-mode-p (mode-symbol)
  "Check if MODE-SYMBOL is a tree-sitter mode.
MODE-SYMBOL should be a symbol like 'python-ts-mode or 'python-mode.
Returns t if the mode is a tree-sitter mode (ends with -ts-mode), nil otherwise."
  (when mode-symbol (string-match-p "-ts-mode$" (symbol-name mode-symbol))))
 (defun
  treesit-utils-extract-lang-from-mode (mode-symbol)
  "Extract language name from tree-sitter MODE-SYMBOL.
MODE-SYMBOL should be a tree-sitter mode symbol like 'python-ts-mode.
Returns the language name as a string (e.g., 'python' from 'python-ts-mode'),
or nil if MODE-SYMBOL is not a tree-sitter mode."
  (when
   (treesit-utils-is-ts-mode-p mode-symbol)
   (replace-regexp-in-string "-ts-mode$" "" (symbol-name mode-symbol)))))
(provide 'tree-sitter-utils)
;;; tree-sitter-utils.el ends here
