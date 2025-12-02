;;; dashboard-config.el --- Dashboard Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Dashboard configuration for a customizable startup screen.
;;      Displays recent files, bookmarks, and other useful information.

;;; Code:
(require 'core-constants)
(require 'pkg-system-ui)
(require 'pkg-system-maintenance)
(require 'nerd-icons)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
      (lambda (&rest _) (pkg-system-ui-show-upgrades)))
     (,(nerd-icons-octicon "nf-oct-list_unordered" :height 1.1 :v-adjust 0.0)
      "Installed Packages"
      "List installed packages"
      (lambda (&rest _) (pkg-system-ui-show-installed)))
     (,(nerd-icons-octicon "nf-oct-search" :height 1.1 :v-adjust 0.0)
      "Search Packages"
      "Search for packages"
      (lambda (&rest _) (pkg-system-ui-search)))
     (,(nerd-icons-codicon "nf-cod-trash" :height 1.1 :v-adjust 0.0)
      "Package Cleanup"
      "Remove unused packages and reset metadata cache"
      (lambda (&rest _) (pkg-system-maintenance-cleanup)))
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
    dashboard--config-insert-separator
    dashboard-insert-items
    dashboard-insert-footer))
 (dashboard-setup-startup-hook)
 ;; Force dashboard refresh when opening files at startup
 (add-hook 'emacs-startup-hook #'dashboard-insert-startupify-lists)
 ;; Show dashboard if only scratch buffer is visible after startup
 (add-hook 'emacs-startup-hook #'dashboard--config-show-if-scratch-only))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 dashboard--config-insert-separator () "Insert a centered horizontal line separator."
 (let* ((line-width 80)
        (separator (make-string line-width ?─))
        (padding (/ (- (window-width) line-width) 2))
        (spaces (make-string (max 0 padding) ?\s)))
   (insert "\n\n" spaces separator "\n")))

(defun
 dashboard--config-show-if-scratch-only ()
 "Show dashboard if only `*scratch*' buffer is displayed.
This handles cases where command-line arguments prevent dashboard
from showing at startup, but result in only `*scratch*' being visible."
 (when
  (and
   (string= (buffer-name) "*scratch*") (= (length (window-list)) 1)
   ;; Check no user files are open (allow internal buffers)
   (not
    (cl-some
     (lambda
      (buf)
      (let ((name (buffer-name buf)))
        (and (buffer-file-name buf) (not (string-prefix-p " " name)))))
     (buffer-list))))
  (dashboard-insert-startupify-lists) (dashboard-initialize)))
(provide 'dashboard-config)
;;; dashboard-config.el ends here
