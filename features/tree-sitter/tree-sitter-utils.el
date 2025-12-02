;;; tree-sitter-utils.el --- Tree-sitter Utility Functions -*- lexical-binding: t -*-
;;; Commentary:
;;      Utility functions for working with tree-sitter grammars and functionality.
;;      Provides helpers for grammar management, counting, and availability checks.

;;; Code:
(require 'core-constants)
(require 'core-utils)
(require 'core-logging)
(require 'features-constants)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defconst
 tree-sitter-grammar-prefix
 "libtree-sitter-"
 "Prefix for tree-sitter grammar shared library files.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 treesit-utils-get-installed-grammars ()
 "Get list of installed tree-sitter grammars with details.
Returns a list of plists with :name and :file keys."
 (if
  (not (and (fboundp 'treesit-available-p) (treesit-available-p))) '()
  (let ((grammars '())
        (pattern (format "%s\\([^.]+\\)\\.\\(so\\|dylib\\)$" tree-sitter-grammar-prefix))
        (transform-fn (lambda (file lang-name _ext) (list :name lang-name :file file))))
    ;; Scan the primary grammar directory
    (when-let ((results
                (core-utils-scan-directory-for-pattern
                 features-treesit-grammars-dir pattern transform-fn)))
      (setq grammars (append grammars results)))
    ;; Also check treesit-extra-load-path if it's set
    (when
     (boundp 'treesit-extra-load-path)
     (dolist
      (dir treesit-extra-load-path)
      (when
       (and dir (file-directory-p dir) (not (string= dir features-treesit-grammars-dir)))
       (when-let ((results (core-utils-scan-directory-for-pattern dir pattern transform-fn)))
         (setq grammars (append grammars results))))))
    grammars)))

(defun
 treesit-utils-count-installed-grammars ()
 "Count the number of installed tree-sitter grammars.
Returns the count of .so/.dylib grammar files found in the tree-sitter grammar directory."
 (length (treesit-utils-get-installed-grammars)))

(defun
 treesit-utils-get-mode-mapping (lang)
 "Get the (REGULAR-MODE TS-MODE) pair for LANG by querying treesit-auto.
Returns nil if no mapping is found."
 (when
  (and (boundp 'treesit-auto-recipe-list) treesit-auto-recipe-list)
  (let ((recipe
         (seq-find (lambda (r) (eq (treesit-auto-recipe-lang r) lang)) treesit-auto-recipe-list)))
    (when
     recipe
     (let ((ts-mode (treesit-auto-recipe-ts-mode recipe))
           (remap (treesit-auto-recipe-remap recipe)))
       (when (and ts-mode remap) (list remap ts-mode)))))))

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
  (replace-regexp-in-string "-ts-mode$" "" (symbol-name mode-symbol))))

(defun
 treesit--utils-get-grammar-filename (lang)
 "Get the expected grammar filename for LANG.
LANG should be a string like \"python\" or \"bash\".
Returns filename like \"libtree-sitter-python.so\" (or .dylib on macOS).
Returns nil if LANG is nil."
 (when lang (format "%s%s%s" tree-sitter-grammar-prefix lang (car dynamic-library-suffixes))))

(defun
 treesit-utils-show-info () "Display tree-sitter status information in minibuffer." (interactive)
 (if
  (treesit-available-p)
  (let* ((mode-display-name (format-mode-line mode-name))
         (parent-mode (get major-mode 'derived-mode-parent))
         (parent-mode-name (if parent-mode (symbol-name parent-mode) "none"))
         (is-ts-mode (treesit-utils-is-ts-mode-p major-mode))
         (lang (treesit-utils-extract-lang-from-mode major-mode))
         (grammar-available (when lang (treesit-language-available-p (intern lang))))
         (grammar-file
          (if (and lang grammar-available) (treesit--utils-get-grammar-filename lang) "none")))
    (core-message-plain
     "Tree-Sitter> Mode Name: %s | Mode Symbol: %s | Parent Mode: %s | Tree-sitter: %s | Grammar Installed: %s"
     mode-display-name
     (symbol-name major-mode)
     parent-mode-name
     (if is-ts-mode "yes" "no")
     grammar-file))
  (core-message-warning "Tree-sitter: not available in this Emacs build")))
(provide 'tree-sitter-utils)
;;; tree-sitter-utils.el ends here
