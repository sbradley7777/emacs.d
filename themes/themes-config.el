;;; themes-config.el --- Core Theme Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Core theme and visual appearance configuration

(require 'core-utils)

(with-load-timing
 "themes-config.el"
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Configure the theme
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Zenburn theme configuration - https://github.com/bbatsov/zenburn-emacs
 ;; Customization: https://github.com/bbatsov/zenburn-emacs?tab=readme-ov-file#customization
 (setq zenburn-override-colors-alist '(("zenburn-bg" . "#000000")))
 ;; Load the zenburn theme
 (load-theme 'zenburn t)

 ;; Make this module available for loading with (require 'themes-config)
 (provide 'themes-config))
