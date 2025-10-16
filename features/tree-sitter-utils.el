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
   (let ((grammars '()))
     ;; Scan the primary grammar directory
     (when
      (file-directory-p core-treesit-grammar-dir)
      (dolist
       (file (directory-files core-treesit-grammar-dir nil "\\.\\(so\\|dylib\\)$"))
       (when
        (string-match "libtree-sitter-\\([^.]+\\)\\.\\(so\\|dylib\\)$" file)
        (let ((lang-name (match-string 1 file)))
          (push (list :name lang-name :file file) grammars)))))
     ;; Also check treesit-extra-load-path if it's set
     (when
      (boundp 'treesit-extra-load-path)
      (dolist
       (dir treesit-extra-load-path)
       (when
        (and dir (file-directory-p dir) (not (string= dir core-treesit-grammar-dir)))
        (dolist
         (file (directory-files dir nil "\\.\\(so\\|dylib\\)$"))
         (when
          (string-match "libtree-sitter-\\([^.]+\\)\\.\\(so\\|dylib\\)$" file)
          (let ((lang-name (match-string 1 file)))
            (push (list :name lang-name :file file) grammars)))))))
     (nreverse grammars))))

 (defun
  treesit-utils-count-installed-grammars ()
  "Count the number of installed tree-sitter grammars.
Returns the count of .so/.dylib grammar files found in the tree-sitter grammar directory."
  (length (treesit-utils-get-installed-grammars))))

(provide 'tree-sitter-utils)

;;; tree-sitter-utils.el ends here
