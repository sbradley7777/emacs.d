;;; tree-sitter-config.el --- Tree-sitter Grammar Management Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Configures tree-sitter grammar installation and loading paths.
;;      Ensures grammars are installed to ~/.emacs.d/local/tree-sitter instead of the default location.

(require 'core-constants)
(require 'core-utils)
(require 'core-logging)

(core-utils-with-load-timing
 "tree-sitter-config.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Tree-sitter Grammar Directory Configuration
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;; Define custom tree-sitter grammar directory
 (defvar
  core-treesit-grammar-dir (expand-file-name "tree-sitter" emacs-local-dir)
  "Custom directory for tree-sitter grammar installations.
Uses emacs-local-dir constant (~/.emacs.d/local/tree-sitter).")

 (core-message-config "Tree-sitter grammar directory: %s" core-treesit-grammar-dir)

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Configure Search Path
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;; Configure tree-sitter to search in custom directory first
 (setq treesit-extra-load-path (list core-treesit-grammar-dir))
 (core-message-config "treesit-extra-load-path: %s" treesit-extra-load-path)

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Redirect Grammar Installations
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;; Redirect all grammar installations to custom directory
 (advice-add
  'treesit-install-language-grammar
  :around
  (lambda
   (orig-fun lang &optional out-dir)
   "Install tree-sitter grammars to custom directory.
Uses core-treesit-grammar-dir unless OUT-DIR is explicitly provided."
   (let ((install-dir (or out-dir core-treesit-grammar-dir)))
     (core-message-info "Installing %s grammar to: %s" lang install-dir)
     (funcall orig-fun lang install-dir))))

 (core-message-success "Tree-sitter grammar management configured")
 (core-message-info "Grammars will install to: %s" core-treesit-grammar-dir))

(provide 'tree-sitter-config)

;;; tree-sitter-config.el ends here
