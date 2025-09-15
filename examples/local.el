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
;; Theme Configuration
;; Set your preferred theme - will be loaded automatically after initialization
(message "📝 === local.el: Theme configuration starting ===")
(message "📝 Display type: %s" (if (display-graphic-p) "GUI" "Terminal"))
(message
 "📝 Before setting: user-preferred-theme = %s"
 (if (boundp 'user-preferred-theme) user-preferred-theme 'unbound))
(setq user-preferred-theme 'doom-1337) ; Active: doom-1337 (hacker-inspired dark theme)
(message "📝 After setting: user-preferred-theme = %s" user-preferred-theme)
(message
 "📝 Current active theme: %s"
 (if
  (boundp 'custom-enabled-themes)
  (if custom-enabled-themes (car custom-enabled-themes) 'none)
  'unbound))
(message
 "📝 Theme system status: %s"
 (if
  (boundp 'themes-config--user-theme-loaded)
  (if themes-config--user-theme-loaded "ready for override" "pending reload")
  "not initialized"))
(message "📝 === local.el: Theme configuration finished ===")
(message
 "📝 Note: Your preferred theme (%s) will be applied after all configuration modules load"
 user-preferred-theme)

;; Available Doom Theme Options:
;; See https://github.com/doomemacs/themes for full collection

;; Recommended themes:
;; (setq user-preferred-theme 'doom-1337)           ; Hacker-inspired dark theme
;; (setq user-preferred-theme 'doom-Iosvkem)        ; Clean, modern dark theme
;; (setq user-preferred-theme 'doom-gruvbox)        ; Retro groove colors
;; (setq user-preferred-theme 'doom-material-dark)  ; Material design dark variant
;; (setq user-preferred-theme 'doom-monokai-machine) ; Enhanced Monokai colors
;; (setq user-preferred-theme 'doom-tomorrow-night) ; Clean, minimal design
;; (setq user-preferred-theme 'doom-peacock)        ; Vibrant, colorful theme

;; Built-in theme alternatives:
;; (setq user-preferred-theme 'wombat)            ; Built-in dark theme
;; (setq user-preferred-theme 'tango-dark)        ; Built-in tango variant

;; Theme-specific customizations (optional)
(setq
 user-theme-customizations
 '((doom-1337 . ((whitespace-style . (face trailing tabs tab-mark)))) ; Disable line length highlighting for doom-1337
   (wombat . ((custom-safe-themes . t))) ; Allow wombat without confirmation
   (doom-zenburn . ((doom-themes-enable-bold . t))) ; Enable bold fonts for doom-zenburn
   (doom-material . ((doom-themes-enable-italic . t))))) ; Enable italics for doom-material

;; Hook to refresh whitespace-mode after theme changes for doom-1337
(defun
 refresh-whitespace-for-doom-1337
 (theme)
 "Refresh whitespace-mode when doom-1337 theme is loaded."
 (when (eq theme 'doom-1337) (global-whitespace-mode -1) (global-whitespace-mode 1)))

(add-hook 'enable-theme-functions 'refresh-whitespace-for-doom-1337)
;;
;; ;; Machine-specific paths
;; (setq python-shell-interpreter "/usr/local/bin/python3")
;;
;; ;; Personal keybindings
;; (global-set-key (kbd "C-c p") 'my-personal-function)
;; (global-set-key (kbd "C-c t") 'switch-theme)  ; Quick theme switching
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

(message "📝 === local.el: Loading local user configuration ===")

;; Add your local configuration below this line
;; ============================================

;; Font Configuration
;; ------------------
;; Set default font size for GUI mode
;; Common sizes: 60 (6pt), 90 (9pt), 100 (10pt), 110 (11pt), 120 (12pt), 140 (14pt)
(when
 (display-graphic-p)
 (set-face-attribute 'default nil :height 90)) ; Height is in 1/10th points, so 90 = 9pt

;; macOS XQuartz Key Mapping Fix
;; -----------------------------
;; In XQuartz make sure that the following is enabled in "Settings"-> "Input" -> "Option key sends Alt_L and Alt_R".
;;
;; Fix Command/Alt key swapping when using Emacs GUI over SSH from macOS with XQuartz
(when
 (and (display-graphic-p) (eq system-type 'gnu/linux))
 ;; Make Option key work as Meta in GUI mode (instead of printing special characters)
 (setq x-alt-keysym 'meta)
 ;; Also try setting the meta keysym
 (setq x-meta-keysym 'alt))
(message "📝 === local.el: The loading of local user configuration finished ===")

;; ============================================
;; End of local configuration

(message "✅  Local user configuration loaded successfully")

(provide 'local)
;;; local.el ends here
