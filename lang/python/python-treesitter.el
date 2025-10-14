;;; python-treesitter.el --- Python Tree-sitter Specific Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Python-specific configuration for tree-sitter mode.
;;      Tree-sitter automatic mode selection is handled by treesit-auto package (core-packages.el).

(require 'core-constants)
(require 'core-logging)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Python Tree-sitter Mode Hook
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Apply Python indentation settings to python-ts-mode
(add-hook
 'python-ts-mode-hook
 (lambda
  ()
  "Configure Python tree-sitter mode indentation."
  (setq indent-tabs-mode nil)
  (setq python-indent core-tab-width)
  (electric-indent-mode 1)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; LSP Integration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Add python-ts-mode to Eglot LSP server map (deferred until features-constants loads)
(with-eval-after-load
 'features-constants
 (add-to-list 'features-eglot-lsp-server-map '(python-ts-mode . "pylsp"))
 (core-message-config "Added python-ts-mode to Eglot LSP server map"))

(provide 'python-treesitter)

;;; python-treesitter.el ends here
