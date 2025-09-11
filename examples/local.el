;;; local.el --- Local User Configuration (Not Version Controlled) -*- lexical-binding: t -*-

;;; Commentary:
;;
;; This file is for local, user-specific Emacs configuration that should NOT be
;; committed to version control. It's loaded automatically by init.el if it exists.
;;
;; PURPOSE:
;; --------
;; • Machine-specific settings (paths, system-dependent configurations)
;; • Personal preferences that differ from the shared configuration
;; • Experimental settings you want to test without affecting the main config
;; • Private or sensitive configuration (API keys, personal info, etc.)
;; • Override any settings from the main configuration
;;
;; USAGE:
;; ------
;; This file is loaded AFTER all the main configuration modules, so you can:
;; • Override any variables or settings defined in the main config
;; • Add additional packages or features
;; • Customize keybindings
;; • Set machine-specific variables
;;
;; EXAMPLES:
;; ---------
;; ;; Override theme
;; (load-theme 'wombat t)
;;
;; ;; Machine-specific paths
;; (setq python-shell-interpreter "/usr/local/bin/python3")
;;
;; ;; Personal keybindings
;; (global-set-key (kbd "C-c p") 'my-personal-function)
;;
;; ;; Private settings
;; (setq user-full-name "Your Full Name"
;;       user-mail-address "your.email@example.com")
;;
;; LOCATION:
;; ---------
;; This file should be placed at: ~/.emacs.d/local.el
;; It is automatically loaded by init.el if it exists.
;;
;; IMPORTANT:
;; ----------
;; • This file should be added to .gitignore to prevent accidental commits
;; • Keep sensitive information out of version-controlled config files
;; • Use this file sparingly - most configuration should go in the main config
;;

;;; Code:

(message "🔄  Loading local user configuration...")

;; Add your local configuration below this line
;; ============================================


;; ============================================
;; End of local configuration

(message "✅  Local user configuration loaded successfully")

(provide 'local)
;;; local.el ends here
