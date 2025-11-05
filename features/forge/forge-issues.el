;;; forge-issues.el --- Forge issue management commands -*- lexical-binding: t -*-

;;; Commentary:
;;      Interactive user commands for working with Forge issues.
;;      Provides commands for listing, viewing, and managing issues.
(require 'core-utils)
(require 'core-logging)
(require 'forge-constants)
(core-utils-with-load-timing
 "forge-issues.el"
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Issue List Commands
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defvar forge-issues-list--current-width 'compact "Current width state of forge issues window.")
 (defun
  forge-issues-list--find-forge-window ()
  "Find the forge topic window if it exists.
Returns the window displaying a forge topic buffer, or nil if not found."
  (let ((forge-window nil))
    (walk-windows
     (lambda
      (win)
      (with-current-buffer
       (window-buffer win) (when (derived-mode-p 'forge-topics-mode) (setq forge-window win))))
     nil t)
    forge-window))
 (defun
  forge-issues-list--resize-forge-window
  (window new-width)
  "Resize WINDOW to NEW-WIDTH (fraction of frame width)."
  (let* ((frame-width (frame-width))
         (desired-width (floor (* frame-width new-width)))
         (current-width (window-width window))
         (delta (- desired-width current-width)))
    (when (/= delta 0) (window-resize window delta t))))
 (defun
  forge-issues-list (&optional repo)
  "List forge issues with toggle between 30% and 50% width.
When buffer is closed, opens at 30%. When buffer is open, toggles between 30% and 50%.
Optional REPO argument specifies which repository to list issues for."
  (interactive)
  (let ((existing-window (forge-issues-list--find-forge-window)))
    (if
     existing-window
     (if
      (eq forge-issues-list--current-width 'compact)
      (progn
       (forge-issues-list--resize-forge-window
        existing-window forge-issues-expanded-width)
       (setq forge-issues-list--current-width 'expanded))
      (forge-issues-list--resize-forge-window existing-window forge-issues-compact-width)
      (setq forge-issues-list--current-width 'compact))
     (condition-case err
         (progn
          (unless
           (require 'forge-topics nil t)
           (error "Forge package not available. Install it with: M-x package-install RET forge"))
          (unless (magit-gitdir) (user-error "Not in a git repository"))
          (let ((repository (or repo (forge-get-repository :tracked))))
            (unless
             repository
             (error "No forge repository found. Ensure this repository is tracked by forge"))
            (forge-topics-setup-buffer repository nil :type 'issue)
            (setq forge-issues-list--current-width 'compact)))
       (user-error
        (let ((err-msg (error-message-string err)))
          (if
           (string-match-p "Cannot use.*yet" err-msg)
           (progn
            (let ((clean-msg (car (split-string err-msg "\n"))))
              (core-message-warning
               "%s Run M-x forge-pull (or N r) to fetch repository data from the forge"
               clean-msg)))
           (core-message-warning "%s" err-msg))))
       (error
        (let ((err-msg (error-message-string err)))
          (if
           (string-match-p "Cannot use.*yet" err-msg)
           (let ((clean-msg (car (split-string err-msg "\n"))))
             (core-message-warning
              "%s Run M-x forge-pull (or N r) to fetch repository data from the forge" clean-msg))
           (core-message-error "Failed to list issues: %s" err-msg))))))))

 (core-message-config "Forge issue commands loaded"))
(provide 'forge-issues)
;;; forge-issues.el ends here
