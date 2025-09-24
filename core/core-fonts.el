;;; core-fonts.el --- Font Management and Installation -*- lexical-binding: t -*-
;;; Commentary:
;;      Centralized font management for icon packages and typography.
;;      Handles automatic installation and verification of required fonts.
;;
;;      IMPORTANT: Package installation (via package.el) only installs Emacs Lisp code.
;;      Font installation is a separate step that downloads actual font files (.ttf, .otf)
;;      to your system font directory (~/.local/share/fonts/) so icons are visible.
;;
;;      FONT INSTALLATION DETAILS:
;;      - Fonts are installed SYSTEM-WIDE, not just for Emacs
;;      - Location: ~/.local/share/fonts/ (Linux) or ~/Library/Fonts/ (macOS)
;;      - Available to ALL applications after installation (terminals, browsers, etc.)
;;      - Your terminal can use these fonts if configured (e.g., set iTerm2 font to "Hack Nerd Font")
;;      - Emacs uses fonts directly for icon display in buffers and UI elements
;;      - Terminal integration requires manual font configuration in terminal settings

(require 'core-constants)
(require 'core-utils)

(core-utils-with-load-timing
 "core-fonts.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Font Installation Functions
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (defun
  fonts-install-all-the-icons ()
  "Install all-the-icons fonts if not already installed.
Checks for font availability before installation to avoid duplicates."
  (when
   (package-installed-p 'all-the-icons)
   (condition-case err
       (progn
        (require 'all-the-icons)
        (unless
         (find-font (font-spec :name "all-the-icons"))
         (message "📦  Installing all-the-icons fonts...")
         (all-the-icons-install-fonts t)
         (message "✅  all-the-icons fonts installed successfully")))
     (error
      (message
       "⚠️  all-the-icons package not ready for font installation: %s"
       (error-message-string err))))))

 (defun
  fonts-check-all-the-icons () "Check if all-the-icons fonts are properly installed."
  (if
   (find-font (font-spec :name "all-the-icons"))
   (message "✅  all-the-icons fonts are available")
   (message "⚠️  all-the-icons fonts not found - may need installation")))

 (defun
  fonts-install-nerd-icons ()
  "Install nerd-icons fonts if not already installed.
Required for treemacs-nerd-icons package."
  (when
   (package-installed-p 'nerd-icons)
   (condition-case err
       (progn
        (require 'nerd-icons)
        (unless
         (find-font (font-spec :name "Symbols Nerd Font Mono"))
         (message "📦  Installing nerd-icons fonts...")
         (nerd-icons-install-fonts t)
         (message "✅  nerd-icons fonts installed successfully")))
     (error
      (message
       "⚠️  nerd-icons package not ready for font installation: %s" (error-message-string err))))))

 (defun
  fonts-check-nerd-icons () "Check if nerd-icons fonts are properly installed."
  (if
   (find-font (font-spec :name "Symbols Nerd Font Mono"))
   (message "✅  nerd-icons fonts are available")
   (message "⚠️  nerd-icons fonts not found - may need installation")))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Automatic Font Installation
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;; Install fonts automatically after packages are available
 (fonts-install-all-the-icons) (fonts-install-nerd-icons)

 (message "⚙️  Font management system loaded - supports all-the-icons and nerd-icons"))

(provide 'core-fonts)
