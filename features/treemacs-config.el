;;; treemacs-config.el --- Treemacs Project Tree Navigation -*- lexical-binding: t -*-
;;; Commentary:
;;      Treemacs configuration for file and project tree navigation.
;;      Provides a sidebar with project structure, git integration, and enhanced navigation.

(require 'core-constants)
(require 'core-utils)

(core-utils-with-load-timing
 "treemacs-config.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Treemacs Package Installation
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;; Add treemacs packages to the development package list
 (when
  (boundp 'core-packages-development)
  (add-to-list 'core-packages-development 'treemacs)
  (add-to-list 'core-packages-development 'treemacs-projectile)
  (add-to-list 'core-packages-development 'treemacs-icons-dired))

 ;; Ensure MELPA is available for Treemacs packages
 (require 'package)
 (unless
  (assoc "melpa" package-archives)
  (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t))

 ;; Install treemacs packages if not already installed
 (unless
  (package-installed-p 'treemacs)
  (message "🔄  Refreshing package contents for Treemacs installation...")
  (message "ℹ️  Available archives: %s" (mapcar 'car package-archives))
  (package-refresh-contents))

 (dolist
  (pkg '(treemacs treemacs-projectile treemacs-icons-dired))
  (unless
   (package-installed-p pkg)
   (condition-case err
       (progn
        (message "📦  Installing %s..." pkg) (package-install pkg) (message "✅  Installed %s" pkg))
     (error
      (message "❌  Failed to install %s: %s" pkg (error-message-string err))))))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Treemacs Configuration
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

  ;; Configure icons and display
  (when (display-graphic-p) (treemacs-load-theme "Default"))

  ;; Enable useful modes
  (treemacs-follow-mode t)
  (treemacs-filewatch-mode t)
  (treemacs-fringe-indicator-mode 'always)
  (treemacs-project-follow-mode t)

  ;; Custom function to intelligently toggle treemacs for current project
  (defun
   treemacs-smart-toggle
   ()
   "Toggle Treemacs, switching to current project if needed."
   (interactive)
   (if
    (and (treemacs-get-local-window) (treemacs-is-treemacs-window-selected?))
    ;; If currently in treemacs window, close it
    (delete-window)
    (if
     (treemacs-get-local-window)
     ;; If treemacs is visible but not selected, close it (simple toggle)
     (treemacs--select-not-visible)
     ;; Treemacs not visible, open with current project
     (when
      (buffer-file-name)
      (let ((project-root
             (or
              (when (featurep 'projectile) (projectile-project-root))
              (vc-root-dir)
              (file-name-directory (buffer-file-name)))))
        (when project-root (treemacs-add-and-display-current-project-exclusively)))))))

  ;; Global keybindings for treemacs
  (global-set-key (kbd "<f5>") 'treemacs-smart-toggle)
  (global-set-key (kbd "C-x t 1") 'treemacs-delete-other-windows)
  (global-set-key (kbd "C-x t t") 'treemacs)
  (global-set-key (kbd "C-x t C-t") 'treemacs-find-file)

  (message "✅  Treemacs loaded and configured successfully"))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Dired Integration
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;; Configure dired integration
 (with-eval-after-load
  'dired
  (when
   (featurep 'treemacs-icons-dired)
   (add-hook 'dired-mode-hook 'treemacs-icons-dired-enable-once))))

(provide 'treemacs-config)
