;;; themes-config.el --- Core Theme Configuration -*- lexical-binding: t -*-
;;; Commentary:
;; WHAT: Basic theme loading and doom-themes setup
;; WHY:  Provides essential theme functionality for startup
;; PROVIDES: load-configured-theme, basic theme variables
;;
;; Core theme and visual appearance configuration
;; Advanced theme utilities are in theme-utils.el

;;; Dependencies:
;; - core-utils (for core-utils-with-load-timing)
;; - doom-themes package


(core-utils-with-load-timing
 "themes-config.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Theme Configuration Variables
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;; User-configurable theme variables (can be set in local.el)
 (defvar
  themes-config-preferred-theme 'doom-zenburn
  "User's preferred theme. Can be overridden in local.el.
Examples: 'doom-zenburn, 'doom-one, 'doom-gruvbox, 'wombat")

 (defvar
  themes-config-customizations nil
  "User's theme-specific customizations. Can be overridden in local.el.
Format: ((theme-name . ((var1 . value1) (var2 . value2))) ...)
Example: '((doom-zenburn . ((doom-themes-enable-bold . t))))")

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Doom Themes Configuration
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;; Doom themes configuration - applied before theme loading
 (defvar
  themes-config-doom-default-customizations
  '((doom-themes-enable-bold . t)
    (doom-themes-enable-italic . nil) ; Disable italic in terminal to avoid issues
    (doom-themes-treemacs-theme . "doom-atom") (doom-themes-treemacs-enable-variable-pitch . nil))
  "Default doom themes customizations.")

 (defun
  themes-config-apply-doom-customizations
  ()
  "Apply doom-themes-specific customizations."
  (require 'doom-themes)
  (dolist (custom themes-config-doom-default-customizations) (set (car custom) (cdr custom)))

  ;; Terminal-specific adjustments to prevent nil attribute warnings
  (when (not (display-graphic-p)) (setq doom-themes-enable-italic nil))

  ;; Enable doom-themes enhancements (with error handling for terminal compatibility)
  (condition-case err
      (progn (doom-themes-visual-bell-config) (doom-themes-org-config))
    (error
     (core-message-warning
      "Some doom-themes features disabled for terminal compatibility: %s"
      (error-message-string err)))))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Core Theme Loading
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (defun
  themes-config-apply-customizations (theme) "Apply customizations for the specified THEME."
  ;; Apply doom-themes configuration for all themes
  (themes-config-apply-doom-customizations)
  ;; Apply any user customizations from local.el
  (when-let ((customs (cdr (assq theme themes-config-customizations))))
    (dolist (custom customs) (set (car custom) (cdr custom)))))

 (defun
  themes-config-load-configured-theme
  ()
  "Load the user's preferred theme with appropriate customizations."
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
       ;; Apply theme-specific customizations before loading
       (themes-config-apply-customizations theme)

       ;; Load the theme
       (condition-case err
           (progn
            ;; Clear all existing themes to prevent background conflicts
            (mapc #'disable-theme custom-enabled-themes)
            (load-theme theme t)
            (core-message-success "Successfully loaded theme: %s" theme)
            ;; Apply modeline face customizations if available
            (when (fboundp 'modeline-faces-apply-for-theme) (modeline-faces-apply-for-theme theme))
            ;; Apply post-load fixes for terminal compatibility
            (when
             (and (not (display-graphic-p)) (string-match-p "^doom-" (symbol-name theme)))
             (core-message-theme "Applied terminal compatibility fixes for %s" theme))
            ;; Customize region (selection) to be distinct from hl-line
            ;; Use a blue-tinted background for selections
            (set-face-attribute
             'region
             nil
             :background "#264F78"
             :foreground 'unspecified
             :extend t))
         (error
          (core-message-error "Failed to load theme '%s': %s" theme (error-message-string err))
          ;; Fallback to doom-zenburn
          (core-message-theme "Loading fallback theme: doom-zenburn")
          (themes-config-apply-customizations 'doom-zenburn)
          (load-theme 'doom-zenburn t)
          (core-message-success "Loaded fallback theme: doom-zenburn")
          ;; Apply region customization for fallback theme too
          (set-face-attribute
           'region
           nil
           :background "#264F78"
           :foreground 'unspecified
           :extend t))))))))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Load Theme on Startup
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Load user's preferred theme after all configuration is complete
 (add-hook 'emacs-startup-hook #'themes-config-load-configured-theme))

;; Make this module available for loading with (require 'themes-config)
(provide 'themes-config)

;;; themes-config.el ends here
