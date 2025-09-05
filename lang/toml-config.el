;;; toml-config.el --- TOML Language Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      TOML mode support and configuration for .toml files including pyproject.toml

(require 'core-constants)
(require 'utils)

(with-load-timing
 "toml-config.el"
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Load TOML mode support
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (require 'toml-mode)

 ;; File associations for TOML files
 (add-to-list 'auto-mode-alist '("\\.toml\\'" . toml-mode))
 (add-to-list 'auto-mode-alist '("pyproject\\.toml\\'" . toml-mode))
 (add-to-list 'auto-mode-alist '("Cargo\\.toml\\'" . toml-mode))

 ;; TOML-specific configuration
 (add-hook
  'toml-mode-hook
  (lambda
   () "Configure TOML mode settings."
   (setq indent-tabs-mode nil) ; Use spaces for indentation
   (setq tab-width core-tab-width) ; Use standard tab width
   (electric-indent-mode 1))) ; Enable electric indentation

 ;; Make this module available for loading with (require 'toml-config)
 (provide 'toml-config))
