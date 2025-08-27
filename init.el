;;; init.el --- Emacs Configuration Entry Point
;;; Commentary:
;;      Main entry point for Emacs configuration.
;;      Loads configuration modules in the correct order.

(message "Loading init.el...")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Performance optimizations for faster startup
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Increase garbage collection threshold during startup (default is 800KB)
(setq gc-cons-threshold (* 50 1000 1000)) ; 50MB

;; Reduce file handler checks during startup for better performance
(defvar default-file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)

;; Restore normal values after startup is complete
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 2 1000 1000)) ; 2MB for normal operation
            (setq file-name-handler-alist default-file-name-handler-alist)
            (message "Emacs startup complete. GC threshold restored.")))

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
