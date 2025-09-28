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
;; Theme Configuration (with example debug output)
;; Set your preferred theme - will be loaded automatically after initialization
(core-message-loading "=== local.el: Theme configuration starting ===")
(core-message-theme "Display type: %s" (if (display-graphic-p) "GUI" "Terminal"))
(core-message-theme
 "Before setting: user-preferred-theme = %s"
 (if (boundp 'themes-config-preferred-theme) themes-config-preferred-theme 'unbound))
(setq themes-config-preferred-theme 'doom-1337) ; Active: doom-1337 (hacker-inspired dark theme)
(core-message-theme "After setting: user-preferred-theme = %s" themes-config-preferred-theme)
(core-message-theme
 "Current active theme: %s"
 (if
  (boundp 'custom-enabled-themes)
  (if custom-enabled-themes (car custom-enabled-themes) 'none)
  'unbound))
(core-message-theme
 "Theme system status: %s"
 (if
  (boundp 'themes-config--user-theme-loaded)
  (if themes-config--user-theme-loaded "ready for override" "pending reload")
  "not initialized"))

;; Available Doom Theme Options:
;; See https://github.com/doomemacs/themes for full collection
;; Recommended themes (uncomment one line to change the theme):
;; (setq themes-config-preferred-theme 'doom-1337)           ; Hacker-inspired dark theme
;; (setq themes-config-preferred-theme 'doom-Iosvkem)        ; Clean, modern dark theme
;; (setq themes-config-preferred-theme 'doom-gruvbox)        ; Retro groove colors
;; (setq themes-config-preferred-theme 'doom-material-dark)  ; Material design dark variant
;; (setq themes-config-preferred-theme 'doom-monokai-machine) ; Enhanced Monokai colors
;; (setq themes-config-preferred-theme 'doom-tomorrow-night) ; Clean, minimal design
;; (setq themes-config-preferred-theme 'doom-peacock)        ; Vibrant, colorful theme

;; Built-in theme alternatives (uncomment one line to use):
;; (setq themes-config-preferred-theme 'wombat)            ; Built-in dark theme
;; (setq themes-config-preferred-theme 'tango-dark)        ; Built-in tango variant

;; Global Theme Customizations
;; Allow all themes without confirmation
(setq custom-safe-themes t)

;; Enable bold fonts for all doom themes
(setq doom-themes-enable-bold t)

;; Enable italic fonts for all doom themes
(setq doom-themes-enable-italic t)

;; Global whitespace customizations - applies to all themes
;; Disable line length highlighting for all themes by removing 'lines-tail from whitespace-style
(setq whitespace-style '(face trailing tabs tab-mark))
;; Refresh whitespace-mode to apply the new style
(when
 (bound-and-true-p global-whitespace-mode) (global-whitespace-mode -1) (global-whitespace-mode 1))
(core-message-info
 "The preferred theme (%s) will be applied after all configuration modules ared loaded"
 themes-config-preferred-theme)
(core-message-info "=== local.el: Theme configuration finished ===")

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
;; 4. PYTHON VIRTUAL ENVIRONMENT CONFIGURATION
;; ============================================
;; Python virtual environment modeline color (optional)
;; Customize the color of the [venv: project-name] indicator in the modeline
;; By default, no special color is applied (uses normal modeline text color)
;; Options: "lightcoral", "red", "orange", "green", "blue", "purple", "#ff7f7f", etc.
(setq pyvenv-modeline-color "lightcoral")

;; ============================================
;; 5. TREEMACS ICON THEME OVERRIDE (OPTIONAL)
;; ============================================
;; By default, treemacs uses the "Default" theme (simple text indicators)
;; for both GUI and terminal modes.
;;
;; Set your preferred treemacs theme here:
;; Options: "nerd-icons", "Default", or nil (use defaults)
;;(setq treemacs-theme-name "Default")
(setq treemacs-theme-name "nerd-icons")

;; Apply the theme override
(when
 treemacs-theme-name
 (with-eval-after-load
  'treemacs
  (cond
   ;; Nerd Icons theme
   ((and (string= treemacs-theme-name "nerd-icons") (package-installed-p 'treemacs-nerd-icons))
    (require 'treemacs-nerd-icons)
    (treemacs-load-theme "nerd-icons")
    (core-message-success "Treemacs nerd-icons theme loaded (overriding default theme)"))

   ;; Default theme
   ((string= treemacs-theme-name "Default")
    (treemacs-load-theme "Default")
    (core-message-success "Treemacs Default theme loaded (overriding automatic selection)")))))

;; ============================================
;; 6. ADDITIONAL EXAMPLES (COMMENTED OUT)
;; ============================================
;; Theme-specific customizations (optional - for exceptions to global settings)
;; (setq themes-config-customizations
;;       '((some-theme . ((custom-setting . custom-value)))))      ; Example theme-specific override

;; Machine-specific paths
;; (setq python-shell-interpreter "/usr/local/bin/python3")

;; Personal keybindings
;; (global-set-key (kbd "C-c p") 'my-personal-function)
;; (global-set-key (kbd "C-c t") 'switch-theme)  ; Quick theme switching

;; Private settings
;; (setq user-full-name "Your Full Name"
;;       user-mail-address "your.email@example.com")

(core-message-info "=== local.el: The loading of local user configuration finished ===")
(core-message-success "Local user configuration loaded successfully")

(provide 'local)
