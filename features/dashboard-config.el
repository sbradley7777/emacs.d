;;; dashboard-config.el --- Dashboard Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Dashboard configuration for a customizable startup screen.
;;      Displays recent files, bookmarks, and other useful information.
(require 'core-constants)
(require 'core-utils)
(require 'package-ui)
(require 'package-maintenance)
(core-utils-with-load-timing
 "dashboard-config.el"
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Dashboard Configuration
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  dashboard--insert-separator () "Insert a centered horizontal line separator."
  (let* ((line-width 80)
         (separator (make-string line-width ?─))
         (padding (/ (- (window-width) line-width) 2))
         (spaces (make-string (max 0 padding) ?\s)))
    (insert "\n\n" spaces separator "\n")))
 (use-package
  dashboard
  :ensure t
  :config
  (setq
   dashboard-banner-logo-title
   "Welcome to Emacs"
   dashboard-startup-banner
   2
   dashboard-center-content
   t
   dashboard-vertically-center-content
   nil
   dashboard-show-shortcuts
   t
   dashboard-items
   '((recents . 5) (bookmarks . 5))
   dashboard-icon-type
   'nerd-icons
   dashboard-set-heading-icons
   t
   dashboard-set-file-icons
   t
   dashboard-set-navigator
   t
   dashboard-set-init-info
   t
   dashboard-navigator-buttons
   `(((,(nerd-icons-faicon "nf-fa-home" :height 1.1 :v-adjust 0.0)
       "Home"
       "Browse homepage"
       (lambda (&rest _) (browse-url "https://github.com/emacs-dashboard/emacs-dashboard")))
      (,(nerd-icons-codicon "nf-cod-package" :height 1.1 :v-adjust 0.0)
       "Update"
       "Check for package updates"
       (lambda (&rest _) (show-package-upgrades)))
      (,(nerd-icons-octicon "nf-oct-list_unordered" :height 1.1 :v-adjust 0.0)
       "Installed Packages"
       "List installed packages"
       (lambda (&rest _) (show-installed-packages)))
      (,(nerd-icons-octicon "nf-oct-search" :height 1.1 :v-adjust 0.0)
       "Search Packages"
       "Search for packages"
       (lambda (&rest _) (search-packages)))
      (,(nerd-icons-codicon "nf-cod-trash" :height 1.1 :v-adjust 0.0)
       "Package Cleanup"
       "Remove unused packages and reset metadata cache"
       (lambda (&rest _) (core-packages-cleanup)))
      (,(nerd-icons-octicon "nf-oct-tools" :height 1.1 :v-adjust 0.0)
       "Settings"
       "Open settings"
       (lambda (&rest _) (find-file user-init-file)))
      (,(nerd-icons-faicon "nf-fa-refresh" :height 1.1 :v-adjust 0.0)
       "Restart"
       "Restart Emacs"
       (lambda (&rest _) (restart-emacs)))
      (,(nerd-icons-octicon "nf-oct-sign_out" :height 1.1 :v-adjust 0.0)
       "Quit"
       "Quit Emacs"
       (lambda (&rest _) (save-buffers-kill-terminal)))))
   dashboard-startupify-list
   '(dashboard-insert-banner
     dashboard-insert-newline
     dashboard-insert-banner-title
     dashboard-insert-newline
     dashboard-insert-navigator
     dashboard-insert-newline
     dashboard-insert-init-info
     dashboard--insert-separator
     dashboard-insert-items
     dashboard-insert-footer))
  (dashboard-setup-startup-hook)
  ;; Force dashboard refresh when opening files at startup
  (add-hook 'emacs-startup-hook #'dashboard-insert-startupify-lists)))
(provide 'dashboard-config)
