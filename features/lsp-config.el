;;; lsp-config.el --- General Eglot LSP Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      General Eglot configuration that applies to all languages.
;;      Language-specific server configurations should be in lang/<language>/eglot-config.el files.

(require 'features-constants)
(require 'core-utils)
(require 'python-constants)

(with-load-timing "lsp-config.el" (message "Loading general LSP configuration..."))

;; Make this module available for loading with (require 'lsp-config)
(provide 'lsp-config)
