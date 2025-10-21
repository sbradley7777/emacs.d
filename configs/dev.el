;;; dev.el --- Development Configuration Template (Not Version Controlled) -*- lexical-binding: t -*-
;;; Commentary:
;;
;; This file serves as a template for temporary development and testing of new
;; Emacs configurations without affecting the core configuration or permanent
;; local settings.
;;
;; PURPOSE:
;; --------
;; • Testing new packages, features, or configuration changes
;; • Temporary modifications for development work
;; • Experimenting with settings before adding them to the main config
;; • Quick configuration testing without committing to permanent changes
;;
;; USAGE:
;; ------
;; Copy this file to ~/.emacs.d/dev.el and modify as needed for testing.
;; The dev.el file in your home directory will be loaded automatically if it
;; exists, after all main configuration, custom.el, and local.el have loaded.
;;
;; Unlike local.el (for permanent local settings), dev.el is intended for
;; temporary testing and development work.
;;

(require 'core-logging)
(core-message-debug "Loading development configuration...")
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DEVELOPMENT CONFIGURATION
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Add your temporary configuration testing here


;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(core-message-success "Development configuration loaded successfully")
(provide 'dev)
