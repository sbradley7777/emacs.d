;;; core-registry.el --- Generic Registry System -*- lexical-binding: t -*-
;;; Commentary:
;; Main entry point for the generic registry system.
;; Provides a unified interface for all registry operations:
;; - Querying and accessing registry data
;; - Constructing new registry entries
;; - Validating registry structure
;;
;; Registry Format:
;;   (IDENTIFIER DESCRIPTION MODES . PROPERTIES)
;;
;; Where:
;;   IDENTIFIER  - Symbol uniquely identifying this entry
;;   DESCRIPTION - User-friendly string description
;;   MODES       - List of `major-mode' symbols, or special value (multiple)
;;   PROPERTIES  - Plist of keyword-value pairs
;;
;; Example entry:
;;   (pylsp "Python Language Server" (python-mode python-ts-mode)
;;    :binary "pylsp" :install-hint "pip install python-lsp-server")
;;
;; This abstraction is used by:
;;   - flymake-backend-registry (diagnostic backends)
;;   - features-eglot-lsp-server-registry (LSP servers)
;;
;; To use the registry system:
;;   (require \\='core-registry)
;;
;; This will load all registry modules automatically.

;;; Code:
(require 'core-registry-query)
(require 'core-registry-validation)
(require 'core-registry-constructors)

(provide 'core-registry)
;;; core-registry.el ends here
