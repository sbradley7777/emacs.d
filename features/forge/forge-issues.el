;;; forge-issues.el --- Forge issue management commands -*- lexical-binding: t -*-
;;; Commentary:
;;      Interactive user commands for working with Forge issues.
;;      Provides commands for listing, viewing, and managing issues.

;;; Code:
(require 'core-logging)
(require 'features-constants)
(require 'forge-constants)
(require 'git-utils)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Issue List Commands
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar forge-issues--current-width 'compact "Current width state of forge issues window.")
(defun
 forge-issues--handle-error (err error-type)
 "Handle errors from toggle-forge-issues-window with appropriate messaging.
ERR is the error object, ERROR-TYPE is the type of error caught (user-error or error).
Provides helpful guidance for 'Cannot use repository yet' errors."
 (let ((err-msg (error-message-string err)))
   (if
    (string-match-p "Cannot use.*yet" err-msg)
    (let ((clean-msg (car (split-string err-msg "\n"))))
      (core-message-warning
       "%s Run M-x forge-pull (or N r) to fetch repository data from the forge" clean-msg))
    (if
     (eq error-type 'user-error)
     (core-message-warning "%s" err-msg)
     (core-message-error "Failed to list issues: %s" err-msg)))))
(defun
 forge-issues--kill-orphaned-buffers ()
 "Kill forge buffers that lack proper initialization.
Orphaned buffers have forge-topics-mode but nil forge--buffer-topics-spec,
which causes errors during redisplay when the mode-line is evaluated."
 (dolist
  (buf (buffer-list))
  (with-current-buffer
   buf
   (when
    (and
     (derived-mode-p 'forge-topics-mode)
     (or (not (boundp 'forge--buffer-topics-spec)) (not forge--buffer-topics-spec)))
    (kill-buffer buf)))))
(defun
 forge-issues--find-window ()
 "Find the forge topic window if it exists and is properly initialized.
Returns the window displaying a forge topic buffer, or nil if not found."
 (let ((forge-window nil))
   (walk-windows
    (lambda
     (win)
     (with-current-buffer
      (window-buffer win)
      (when
       (and
        (derived-mode-p 'forge-topics-mode)
        (boundp 'forge--buffer-topics-spec)
        forge--buffer-topics-spec)
       (setq forge-window win))))
    nil t)
   forge-window))
(defun
 forge-issues--resize-window
 (window new-width)
 "Resize WINDOW to NEW-WIDTH (fraction of frame width)."
 (let* ((frame-width (frame-width))
        (desired-width (floor (* frame-width new-width)))
        (current-width (window-width window))
        (delta (- desired-width current-width)))
   (when (/= delta 0) (window-resize window delta t))))
(defun
 toggle-forge-issues-window (&optional repo)
 "Toggle forge issues window with size cycling between 30% and 50% width.
When buffer is closed, opens at 30%. When buffer is open, toggles between 30% and 50%.
Optional REPO argument specifies which repository to list issues for."
 (interactive) (forge-issues--kill-orphaned-buffers)
 (let ((existing-window (forge-issues--find-window)))
   (if
    existing-window
    (if
     (eq forge-issues--current-width 'compact)
     (progn
      (forge-issues--resize-window existing-window features-side-window-expanded-width)
      (setq forge-issues--current-width 'expanded))
     (forge-issues--resize-window existing-window features-side-window-compact-width)
     (setq forge-issues--current-width 'compact))
    (condition-case err
        (progn
         (unless
          (require 'forge-topics nil t)
          (error "Forge package not available. Install it with: M-x package-install RET forge"))
         (unless (git-utils-find-repository-root) (user-error "Not in a git repository"))
         (let ((repository (or repo (forge-get-repository :tracked))))
           (unless
            repository
            (error "No forge repository found. Ensure this repository is tracked by forge"))
           (forge-topics-setup-buffer repository nil :type 'issue)
           (setq forge-issues--current-width 'compact)))
      (user-error
       (forge-issues--handle-error err 'user-error))
      (error
       (forge-issues--handle-error err 'error))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Defensive Mode-Line Handling
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(with-eval-after-load
 'forge-topics
 (defun
  forge-issues--safe-buffer-desc
  (orig-func &rest args)
  "Safely call forge-topics-buffer-desc, returning fallback if buffer is orphaned."
  (if
   (and (boundp 'forge--buffer-topics-spec) forge--buffer-topics-spec) (apply orig-func args)
   (let ((orphaned-buf (current-buffer)))
     (run-with-idle-timer
      0.1 nil
      (lambda
       ()
       (when
        (buffer-live-p orphaned-buf)
        (with-current-buffer
         orphaned-buf
         (when
          (and
           (derived-mode-p 'forge-topics-mode)
           (or (not (boundp 'forge--buffer-topics-spec)) (not forge--buffer-topics-spec)))
          (kill-buffer orphaned-buf))))))
     "Issues")))
 (advice-add 'forge-topics-buffer-desc :around #'forge-issues--safe-buffer-desc))

(with-eval-after-load 'forge-topics (forge-issues--kill-orphaned-buffers))

(add-hook
 'after-init-hook
 (lambda () (run-with-idle-timer 1.0 nil (lambda () (forge-issues--kill-orphaned-buffers)))))

(core-message-config "Forge issue commands loaded")
(provide 'forge-issues)
;;; forge-issues.el ends here
