;;; treemacs-config.el --- Treemacs Project Tree Navigation -*- lexical-binding: t -*-
;;; Commentary:
;;      Treemacs configuration for file and project tree navigation.
;;      Provides a sidebar with project structure, git integration, and enhanced navigation.

(require 'core-constants)
(require 'core-utils)

(core-utils-with-load-timing
 "treemacs-config.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Treemacs Configuration
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Note: Treemacs packages are now installed via the core package system in core-packages.el
 ;;
 ;; Available Themes:
 ;; - "Default" : Built-in theme with simple text indicators (works everywhere)
 ;; - "all-the-icons" : Graphical icons (requires all-the-icons fonts, GUI only)
 ;; - "nerd-icons" : Nerd Font symbols (requires Nerd Fonts installation)
 ;;
 ;; Icon themes require specific fonts and work best in GUI mode.
 ;; Terminal mode automatically uses "Default" theme for maximum compatibility.

 ;; Load and configure Treemacs immediately
 (when
  (package-installed-p 'treemacs)
  (require 'treemacs)

  ;; Basic appearance settings
  (setq
   treemacs-width
   30
   treemacs-indentation
   2
   treemacs-git-integration
   t
   treemacs-collapse-dirs
   3
   treemacs-silent-refresh
   t
   treemacs-change-root-without-asking
   t
   treemacs-sorting
   'alphabetic-case-insensitive-asc
   treemacs-show-hidden-files
   t
   treemacs-never-persist
   nil
   treemacs-is-never-other-window
   nil
   treemacs-goto-tag-strategy
   'refetch-index
   treemacs-project-follow-cleanup
   t)

  ;; Configure icons and display based on environment
  (if
   (display-graphic-p)
   ;; GUI mode - use all-the-icons theme
   (when
    (package-installed-p 'treemacs-all-the-icons)
    (require 'all-the-icons)
    (require 'treemacs-all-the-icons)
    (treemacs-load-theme "all-the-icons")
    (message "📦  all-the-icons theme loaded for GUI"))
   ;; Terminal mode - use Default theme (built-in, no font dependencies)
   (treemacs-load-theme "Default") (message "📦  Default theme loaded for terminal"))

  ;; Enable useful modes
  (treemacs-follow-mode t)
  (treemacs-filewatch-mode t)
  (treemacs-fringe-indicator-mode 'always)
  (treemacs-project-follow-mode t)

  ;; Simplified treemacs toggle function
  (defun
   treemacs-smart-toggle
   ()
   "Toggle Treemacs, switching to current project if needed."
   (interactive)
   (cond
    ;; If treemacs window is selected, close it
    ((and (treemacs-get-local-window) (treemacs-is-treemacs-window-selected?))
     (delete-window))
    ;; If treemacs is visible but not selected, select it
    ((treemacs-get-local-window)
     (treemacs-select-window))
    ;; Treemacs not visible, open it
    (t
     (treemacs)))
   ;; Gentle refresh only if in GUI mode to prevent flicker
   (when
    (and (display-graphic-p) (fboundp 'ui-force-refresh))
    (run-with-timer 0.02 nil 'ui-force-refresh)))

  ;; Global keybindings for treemacs
  (global-set-key (kbd "<f5>") 'treemacs-smart-toggle)
  (global-set-key (kbd "C-x t 1") 'treemacs-delete-other-windows)
  (global-set-key (kbd "C-x t t") 'treemacs)
  (global-set-key (kbd "C-x t C-t") 'treemacs-find-file)

  (message "✅  Treemacs loaded and configured successfully")

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Dired Integration
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;; Configure dired integration - only in GUI mode (icon fonts don't display properly in terminal)
  (when
   (and (display-graphic-p) (package-installed-p 'treemacs-icons-dired))
   (require 'treemacs-icons-dired)
   (add-hook 'dired-mode-hook 'treemacs-icons-dired-enable-once)))

 ;; Ensure F5 binding is always set
 (unless
  (fboundp 'treemacs-smart-toggle)
  (defun
   treemacs-smart-toggle
   ()
   "Fallback function when treemacs is not available."
   (interactive)
   (message "❌  Treemacs not available - package not installed")))

 ;; Always bind F5 to treemacs-smart-toggle
 (global-set-key (kbd "<f5>") 'treemacs-smart-toggle)) ;; End of core-utils-with-load-timing

(provide 'treemacs-config)
