;;; themes-config.el --- Core Theme Configuration -*- lexical-binding: t -*-
;;; Commentary:
;; WHAT: Basic theme loading and doom-themes setup
;; WHY:  Provides essential theme functionality for startup
;; PROVIDES: load-configured-theme, basic theme variables
;;
;; Core theme and visual appearance configuration
;; Advanced theme utilities are in themes-utils.el

(require 'core-constants)
(require 'core-utils)
(require 'core-logging)
(require 'themes-constants)

(core-utils-with-load-timing
 "themes-config.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Theme Configuration Variables
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;; Allow all themes without confirmation prompts
 (setq custom-safe-themes t)

 ;; User-configurable theme variables (can be set in local.el)
 (defvar
  themes-config-preferred-theme 'doom-1337
  "User's preferred theme. Can be overridden in local.el.
Examples: 'doom-1337, 'doom-zenburn, 'doom-one, 'doom-gruvbox, 'wombat")

 (defvar
  themes-config-customizations nil
  "User's theme-specific customizations. Can be overridden in local.el.
Format: ((theme-name . ((var1 . value1) (var2 . value2))) ...)
Example: '((doom-zenburn . ((doom-themes-enable-bold . t))))")

 ;; Doom themes configuration - applied before theme loading
 (defvar
  themes-config-doom-default-customizations
  `((doom-themes-enable-bold . t)
    (doom-themes-enable-italic . t)
    (doom-themes-treemacs-theme . ,themes-doom-treemacs-theme)
    (doom-themes-treemacs-enable-variable-pitch . nil))
  "Default doom themes customizations.")

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Theme-Specific Setup Functions
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (defun
  themes-config-apply-theme-specific-customizations
  (theme)
  "Apply theme-specific customizations for THEME if available."
  (cond
   ((eq theme 'doom-1337)
    (require 'theme-doom-1337)
    (doom-1337-setup))
   ;; Add other theme-specific customizations here
   (t
    nil)))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Core Theme Loading
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (defun
  themes-config-load-configured-theme
  ()
  "Load the user's preferred theme with appropriate customizations."
  (require 'themes-utils) ; Load utilities for generic customization functions
  (let ((theme themes-config-preferred-theme)
        (current-theme (car custom-enabled-themes)))
    (core-message-theme
     "Current theme: %s | Preferred theme: %s" (or current-theme "none") (or theme "none"))
    (if
     (not theme) (core-message-theme "No theme preference set, skipping")
     (if
      (eq theme current-theme) (core-message-theme "Theme %s already loaded" theme)
      (progn
       (core-message-theme "Loading theme: %s" theme)
       ;; Apply generic doom customizations before loading
       (themes-utils--apply-customizations theme)

       ;; Load the theme
       (condition-case err
           (progn
            ;; Clear all existing themes to prevent background conflicts
            (mapc #'disable-theme custom-enabled-themes)
            (load-theme theme t)
            (core-message-success "Successfully loaded theme: %s" theme)
            ;; Apply theme-specific customizations after loading
            (themes-config-apply-theme-specific-customizations theme)
            ;; Apply modeline face customizations if available
            (when (fboundp 'modeline-faces-apply-for-theme) (modeline-faces-apply-for-theme theme))
            ;; Customize region (selection) to be distinct from hl-line
            ;; Use a blue-tinted background for selections
            (set-face-attribute
             'region
             nil
             :background themes-region-background
             :foreground 'unspecified
             :extend t))
         (error
          (core-message-error
           "Failed to load theme '%s': %s" theme (error-message-string err)))))))))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Load Theme on Startup
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Load user's preferred theme after all configuration is complete
 (add-hook 'emacs-startup-hook #'themes-config-load-configured-theme))

;; Make this module available for loading with (require 'themes-config)
(provide 'themes-config)

;;; themes-config.el ends here
