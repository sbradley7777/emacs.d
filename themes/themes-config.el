;;; themes-config.el --- Core Theme Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Core theme and visual appearance configuration
;;      Supports configurable themes via user variables

(require 'core-utils)

(with-load-timing
 "themes-config.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Theme Configuration System
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;; User-configurable theme variables (can be set in local.el)
 (defvar
  user-preferred-theme 'doom-zenburn
  "User's preferred theme. Can be overridden in local.el.
Examples: 'doom-zenburn, 'doom-one, 'doom-gruvbox, 'wombat")

 (defvar
  user-theme-customizations nil
  "User's theme-specific customizations. Can be overridden in local.el.
Format: ((theme-name . ((var1 . value1) (var2 . value2))) ...)
Example: '((doom-zenburn . ((doom-themes-enable-bold . t))))")

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Doom Themes Configuration
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;; Doom themes configuration - applied before theme loading
 ;; Documentation: https://github.com/doomemacs/themes#configuration
 (defvar
  doom-themes-default-customizations
  '((doom-themes-enable-bold . t)
    (doom-themes-enable-italic . nil) ; Disable italic in terminal to avoid issues
    (doom-themes-treemacs-theme . "doom-atom") (doom-themes-treemacs-enable-variable-pitch . nil))
  "Default doom themes customizations.")

 (defun
  apply-doom-themes-customizations
  ()
  "Apply doom-themes-specific customizations."
  (require 'doom-themes)
  (dolist (custom doom-themes-default-customizations) (set (car custom) (cdr custom)))

  ;; Terminal-specific adjustments to prevent nil attribute warnings
  (when
   (not (display-graphic-p))
   ;; Additional terminal compatibility settings
   (setq doom-themes-enable-italic nil))

  ;; Enable doom-themes enhancements (with error handling for terminal compatibility)
  (condition-case err
      (progn
       ;; Enable flashing mode-line on errors (may not work in all terminals)
       (doom-themes-visual-bell-config)
       ;; Corrects (and improves) org-mode's native fontification
       (doom-themes-org-config))
    (error
     (message
      "⚠️  Some doom-themes features disabled for terminal compatibility: %s"
      (error-message-string err)))))

 (defun
  doom-themes-terminal-fixes () "Apply fixes for doom themes in terminal mode to reduce warnings."
  (when
   (not (display-graphic-p))
   ;; Simple approach: just disable the problematic features
   (condition-case err
       (progn
        ;; Disable features that cause nil attribute warnings in terminal
        (setq doom-themes-enable-italic nil))
     (error
      (message "⚠️  Terminal fixes failed: %s" (error-message-string err))))))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Theme Management Functions
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (defun
  apply-theme-customizations (theme) "Apply customizations for the specified THEME."
  ;; Apply doom-themes configuration for all themes (since we're doom-themes focused)
  (apply-doom-themes-customizations)
  ;; Apply any user customizations from local.el
  (when-let ((customs (cdr (assq theme user-theme-customizations))))
    (dolist (custom customs) (set (car custom) (cdr custom)))))

 (defun
  load-configured-theme () "Load the user's preferred theme with appropriate customizations."
  (let ((theme user-preferred-theme)
        (current-theme (car custom-enabled-themes)))
    (message
     "🎨 Current theme: %s | Preferred theme: %s" (or current-theme "none") (or theme "none"))
    (if
     (not theme) (message "🎨 No theme preference set, skipping")
     (if
      (eq theme current-theme) (message "🎨 Theme %s already loaded" theme)
      (progn
       (message "🎨 Loading theme: %s" theme)
       ;; Apply theme-specific customizations before loading
       (apply-theme-customizations theme)

       ;; Load the theme
       (condition-case err
           (progn
            ;; Clear all existing themes to prevent background conflicts
            (mapc #'disable-theme custom-enabled-themes)
            (load-theme theme t)
            (message "✅ Successfully loaded theme: %s" theme)
            ;; Apply post-load fixes for terminal compatibility
            (when
             (and (not (display-graphic-p)) (string-match-p "^doom-" (symbol-name theme)))
             (doom-themes-terminal-fixes)
             (message "🎨 Applied terminal compatibility fixes for %s" theme)
             (message
              "ℹ️  Note: Any theme-related warning messages about 'nil value is invalid' can be safely ignored - they are expected when using doom themes in terminal mode")))
         (error
          (message "❌ Failed to load theme '%s': %s" theme (error-message-string err))
          ;; Fallback to doom-zenburn
          (message "🎨 Loading fallback theme: doom-zenburn")
          (apply-theme-customizations 'doom-zenburn)
          (load-theme 'doom-zenburn t)
          (message "✅ Loaded fallback theme: doom-zenburn"))))))))

 (defun
  switch-theme
  (theme)
  "Interactively switch to a different THEME."
  (interactive
   (list
    (intern
     (completing-read
      "Select theme: "
      (if
       (display-graphic-p)
       ;; GUI mode - all themes available
       '("doom-zenburn"
         "doom-one"
         "doom-dracula"
         "doom-gruvbox"
         "doom-monokai-pro"
         "doom-palenight"
         "doom-tokyo-night"
         "wombat"
         "tango-dark")
       ;; Terminal mode - prioritize terminal-friendly themes
       '("doom-zenburn"
         "doom-gruvbox"
         "doom-molokai"
         "doom-ir-black"
         "doom-tomorrow-night"
         "doom-one"
         "wombat"
         "tango-dark"))
      nil nil nil nil "doom-zenburn"))))
  (message "🎨 Interactive theme switch requested: %s" theme)
  (setq user-preferred-theme theme)
  (load-configured-theme))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Load Theme
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Load user's preferred theme after all configuration is complete
 ;; This ensures local.el preferences are respected without double-loading
 (add-hook 'emacs-startup-hook #'load-configured-theme)) ; Close with-load-timing


;; Make this module available for loading with (require 'themes-config)
(provide 'themes-config)

;;; themes-config.el ends here
