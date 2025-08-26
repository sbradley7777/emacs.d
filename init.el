;;; init.el --- Emacs Configuration Entry Point
;;; Commentary:
;;      Main entry point for Emacs configuration.
;;      Loads configuration modules in the correct order.

(message "Loading init.el...")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Setup configuration directories
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar config-dir (expand-file-name "config" user-emacs-directory))
(defvar lang-dir (expand-file-name "lang" user-emacs-directory))
(defvar themes-dir (expand-file-name "themes" user-emacs-directory))
(defvar custom-dir (expand-file-name "custom" user-emacs-directory))

;; Add directories to load path
(add-to-list 'load-path config-dir)
(add-to-list 'load-path lang-dir)
(add-to-list 'load-path themes-dir)
(add-to-list 'load-path custom-dir)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load configuration modules in order
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Core configuration (order matters)
(require 'core-packages)      ; Package management first
(require 'core-ui)           ; Basic UI setup
(require 'core-editing)      ; Editing preferences
(require 'core-files)        ; File handling
(require 'core-keybindings)  ; Global keybindings

;; Theme configuration
(require 'theme-config)

;; Language-specific configurations
(require 'lang-python)
(require 'lang-yaml)

;; Custom functions
(require 'functions)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; UI tweaks via emacs menu:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Set location of any changes to emacs while running. These changes are not
;; loaded when emacs restarts.
(setq custom-file "~/.emacs.d/custom_prefs.el")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Last message before initialization is complete.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(message "init.el loaded successfully.")