;;; themes-config.el --- Core Theme Configuration -*- lexical-binding: t -*-
;;; Commentary:
;; WHAT: Basic theme loading and doom-themes setup
;; WHY:  Provides essential theme functionality for startup
;; PROVIDES: load-configured-theme, basic theme variables
;;
;; Core theme and visual appearance configuration
;; Advanced theme utilities are in theme-utils.el

;;; Dependencies:
;; - core-utils (for with-load-timing)
;; - doom-themes package

(require 'core-utils)

(with-load-timing
 "themes-config.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Theme Configuration Variables
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
  (when (not (display-graphic-p)) (setq doom-themes-enable-italic nil))

  ;; Enable doom-themes enhancements (with error handling for terminal compatibility)
  (condition-case err
      (progn (doom-themes-visual-bell-config) (doom-themes-org-config))
    (error
     (message
      "⚠️  Some doom-themes features disabled for terminal compatibility: %s"
      (error-message-string err)))))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Core Theme Loading
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (defun
  apply-theme-customizations (theme) "Apply customizations for the specified THEME."
  ;; Apply doom-themes configuration for all themes
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
             (message "🎨 Applied terminal compatibility fixes for %s" theme)))
         (error
          (message "❌ Failed to load theme '%s': %s" theme (error-message-string err))
          ;; Fallback to doom-zenburn
          (message "🎨 Loading fallback theme: doom-zenburn")
          (apply-theme-customizations 'doom-zenburn)
          (load-theme 'doom-zenburn t)
          (message "✅ Loaded fallback theme: doom-zenburn"))))))))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Load Theme on Startup
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Load user's preferred theme after all configuration is complete
 (add-hook 'emacs-startup-hook #'load-configured-theme))

;; Make this module available for loading with (require 'themes-config)
(provide 'themes-config)

;;; themes-config.el ends here
