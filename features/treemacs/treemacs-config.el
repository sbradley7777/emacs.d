;;; treemacs-config.el --- Treemacs Project Tree Navigation -*- lexical-binding: t -*-
;;; Commentary:
;;      Treemacs configuration for file and project tree navigation.
;;      Provides a sidebar with project structure, git integration, and enhanced navigation.

;;; Code:
(require 'core-constants)
(require 'core-utils)
(require 'core-logging)
(require 'treemacs-utils)

;; Declare external functions to suppress byte-compiler warnings
(declare-function treemacs-load-theme "treemacs-themes" (theme-name))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 treemacs-smart-toggle ()
 "Smart toggle for Treemacs file tree sidebar.

Behavior depends on current Treemacs state:
- If Treemacs window is selected: closes it
- If Treemacs is visible but not selected: selects it
- If Treemacs is not visible: opens it at the current file's project root

Opens exclusively at the current project for focused navigation."
 (interactive)
 (cond
  ;; If treemacs window is selected, close it
  ((and (treemacs-get-local-window) (treemacs-is-treemacs-window-selected?))
   (delete-window))
  ;; If treemacs is visible but not selected, select it
  ((treemacs-get-local-window)
   (treemacs-select-window))
  ;; Treemacs not visible, open it at current project
  (t
   (treemacs-add-and-display-current-project-exclusively))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
  treemacs-persist-file
  features-treemacs-persist-file
  treemacs-is-never-other-window
  nil
  treemacs-goto-tag-strategy
  'refetch-index
  treemacs-project-follow-cleanup
  t)

 ;; Load nerd-icons theme (requires Nerd Fonts installation)
 (treemacs-load-user-theme "nerd-icons")

 ;; Enable useful modes
 (treemacs-follow-mode t)
 (treemacs-filewatch-mode t)
 (treemacs-fringe-indicator-mode 'always)
 (treemacs-indent-guide-mode t)
 (treemacs-hide-gitignored-files-mode t)

 ;; Update modeline to show correct theme
 (add-hook
  'treemacs-mode-hook
  (lambda
   ()
   (setq
    mode-line-format
    `("%e" mode-line-front-space
      ,(format "Treemacs: %s" (treemacs-theme->name treemacs--current-theme))))))

 (core-message-success "Treemacs loaded and configured successfully"))

;; Ensure fallback function is defined
(unless
 (fboundp 'treemacs-smart-toggle)
 (defun
  treemacs-smart-toggle
  ()
  "Fallback function when treemacs is not available."
  (interactive)
  (core-message-error "Treemacs not available - package not installed")))
(provide 'treemacs-config)
;;; treemacs-config.el ends here
