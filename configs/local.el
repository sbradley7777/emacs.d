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
(require 'logging)
(core-message-loading "=== local.el: Loading local user configuration ===")
;; ============================================
;; 1. THEME CONFIGURATION
;; ============================================
;; The default theme is doom-1337. To change it, uncomment one of these:
;; (setq themes-config-preferred-theme 'doom-zenburn)        ; Retro warm colors
;; (setq themes-config-preferred-theme 'doom-Iosvkem)        ; Clean, modern dark theme
;; (setq themes-config-preferred-theme 'doom-gruvbox)        ; Retro groove colors
;; (setq themes-config-preferred-theme 'doom-material-dark)  ; Material design dark variant
;; (setq themes-config-preferred-theme 'doom-monokai-machine) ; Enhanced Monokai colors
;; (setq themes-config-preferred-theme 'doom-tomorrow-night) ; Clean, minimal design
;; (setq themes-config-preferred-theme 'doom-peacock)        ; Vibrant, colorful theme
;; (setq themes-config-preferred-theme 'wombat)              ; Built-in dark theme
;; (setq themes-config-preferred-theme 'tango-dark)          ; Built-in tango variant

;; ============================================
;; 2. PLATFORM-SPECIFIC CONFIGURATION
;; ============================================
;; macOS XQuartz Key Mapping Fix
;; In XQuartz make sure that the following is enabled in "Settings"-> "Input" -> "Option key sends Alt_L and Alt_R".
;;
;; Fix Command/Alt key swapping when using Emacs GUI over SSH from macOS with XQuartz
(when
 (and (display-graphic-p) (eq system-type 'gnu/linux))
 ;; Make Option key work as Meta in GUI mode (instead of printing special characters)
 (setq x-alt-keysym 'meta)
 ;; Also try setting the meta keysym
 (setq x-meta-keysym 'alt))

;; ============================================
;; 3. REMOTE DEVELOPMENT (TRAMP) CONFIGURATION
;; ============================================
;; The core configuration is set to be completely silent and NEVER show the
;; TRAMP connection buffer (`*tramp/ssh...*`) by default. Use the settings
;; below to see debugging information.

;; --- TRAMP Verbosity Level ---
;; To see debugging output, you must increase the verbosity level.
;; Uncomment the line below.
;; - A value of `3` shows basic connection messages.
;; - A value of `6` provides detailed debugging, which is recommended
;;   for troubleshooting.
;;
;; Setting this to any value greater than 2 will cause the TRAMP
;; connection buffer to appear.
;;
;; (setq tramp-verbose 6)

;; ============================================
;; 4. ADDITIONAL EXAMPLES (COMMENTED OUT)
;; ============================================
;; Personal keybindings
;; (global-set-key (kbd "C-c p") 'my-personal-function)
;; (global-set-key (kbd "C-c t") 'switch-theme)  ; Quick theme switching

(core-message-info "=== local.el: The loading of local user configuration finished ===")
(core-message-success "Local user configuration loaded successfully")

(provide 'local)
