;;; git-utils.el --- Git Utility Functions -*- lexical-binding: t -*-

;;; Commentary:
;;      Utility functions for git integration.
;;      Provides helper functions for Magit and Forge.
(require 'core-utils)
(require 'core-logging)
(require 'features-constants)
(core-utils-with-load-timing
 "git-utils.el"
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Magit Utility Functions
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  git-utils-magit-display-buffer-side (buffer) "Display BUFFER in side window at configured width."
  (display-buffer
   buffer
   `(display-buffer-in-side-window (side . right) (window-width . ,features-side-window-width))))

 (defun
  git-utils-format-magit-buffer
  ()
  "Format Magit buffer with word-wrapped lines and proper padding."
  (let ((inhibit-read-only t)
        (win-width (window-width)))
    (save-excursion
     (goto-char (point-min))
     (while
      (re-search-forward "^\\(Head:\\|Merge:\\|Push:\\|Pull:\\)\\s-+" nil t)
      (let* ((label-end (point))
             (line-end (line-end-position))
             (fill-prefix (make-string (current-column) ?\s))
             (fill-column (- win-width 2)))
        (when
         (> (- line-end (line-beginning-position)) fill-column)
         (fill-region-as-paragraph label-end line-end)))))))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; User Commands
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defvar user-git-issues--current-width 'compact "Current width state of forge issues window.")
 (defun
  user-git-issues--find-forge-window ()
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
  user-git-issues--resize-forge-window
  (window new-width)
  "Resize WINDOW to NEW-WIDTH (fraction of frame width)."
  (let* ((frame-width (frame-width))
         (desired-width (floor (* frame-width new-width)))
         (current-width (window-width window))
         (delta (- desired-width current-width)))
    (when (/= delta 0) (window-resize window delta t))))
 (defun
  user-git-issues (&optional repo)
  "List forge issues with toggle between 30% and 50% width.
When buffer is closed, opens at 30%. When buffer is open, toggles between 30% and 50%.
Optional REPO argument specifies which repository to list issues for."
  (interactive)
  (let ((existing-window (user-git-issues--find-forge-window)))
    (if
     existing-window
     (if
      (eq user-git-issues--current-width 'compact)
      (progn
       (user-git-issues--resize-forge-window existing-window 0.5)
       (setq user-git-issues--current-width 'expanded))
      (user-git-issues--resize-forge-window existing-window 0.3)
      (setq user-git-issues--current-width 'compact))
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
            (setq user-git-issues--current-width 'compact)))
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

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Git Config Utility Functions
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  git-utils--validate-config-key (key)
  "Validate that KEY is a non-empty string suitable for git config.
Returns t if valid, nil otherwise. Logs warning if invalid.
Allows regex metacharacters that are safe for git config --get-regexp."
  (cond
   ((not (stringp key))
    (core-message-warning "Git config key must be a string, got: %s" (type-of key))
    nil)
   ((string-empty-p key)
    (core-message-warning "Git config key cannot be empty")
    nil)
   ((string-match-p "['\";|&`\n\r]" key)
    (core-message-warning "Git config key contains unsafe shell characters: %s" key)
    nil)
   (t
    t)))

 (defun
  git-utils--validate-hostname (hostname)
  "Validate that HOSTNAME is a valid hostname format.
Returns t if valid, nil otherwise. Does not validate DNS resolution."
  (and
   (stringp hostname)
   (not (string-empty-p hostname))
   (string-match-p "^[a-zA-Z0-9][-a-zA-Z0-9.]*[a-zA-Z0-9]$" hostname)
   (not (string-match-p "\\.\\." hostname))))

 (defun
  git-utils--ensure-git-available ()
  "Check if git command is available. Return t if available, nil otherwise.
Logs a warning if git is not found."
  (if
   (core-utils-check-command-in-path "git") t (core-message-warning "git command not found") nil))

 (defun
  git-utils-git-config-get-regexp (pattern)
  "Get git config values matching PATTERN using git config --global --get-regexp.
Returns list of strings, one per matching config line.
Returns nil if git is not installed, PATTERN is invalid, or no matches found."
  (when
   (and (git-utils--ensure-git-available) (git-utils--validate-config-key pattern))
   (condition-case err
       (with-temp-buffer
        (let ((exit-code
               (call-process "git" nil t nil "config" "--global" "--get-regexp" pattern)))
          (cond
           ((= exit-code 0)
            (let ((output (buffer-string)))
              (when (> (length output) 0) (split-string output "\n" t))))
           ((= exit-code 1)
            (core-message-debug "No git config entries matching pattern: %s" pattern)
            nil)
           (t
            (core-message-warning "git config --get-regexp failed with exit code %d" exit-code)
            nil))))
     (error
      (core-message-error "Failed to read git config: %s" (error-message-string err))
      nil))))

 (defun
  git-utils-git-config-get (key)
  "Get git config value for KEY using git config --global --get.
Returns the value as a string, or nil if not found, KEY is invalid, or git not installed."
  (when
   (and (git-utils--ensure-git-available) (git-utils--validate-config-key key))
   (condition-case err
       (with-temp-buffer
        (let ((exit-code (call-process "git" nil t nil "config" "--global" "--get" key)))
          (cond
           ((= exit-code 0)
            (let ((output (buffer-string)))
              (when (> (length output) 0) (string-trim output))))
           ((= exit-code 1)
            (core-message-debug "Git config key not found: %s" key)
            nil)
           (t
            (core-message-warning
             "git config --get failed for key '%s' with exit code %d" key exit-code)
            nil))))
     (error
      (core-message-error "Failed to read git config key '%s': %s" key (error-message-string err))
      nil))))

 (defun
  git-utils-git-config-get-multiple (base-key suffixes)
  "Get multiple git config values for BASE-KEY with different SUFFIXES.
BASE-KEY should be a format string with one %s placeholder for the suffix.
SUFFIXES should be a list of suffix names.
Returns a plist with keyword versions of SUFFIXES as keys and config values as values.

Example:
  (git-utils-git-config-get-multiple \"emacs-forge.myhost.%s\" '(\"apihost\" \"webhost\" \"type\" \"user\"))
  => (:apihost \"api.example.com\" :webhost \"example.com\" :type \"gitlab\" :user \"john\")"
  (unless
   (and (stringp base-key) (not (string-empty-p base-key)))
   (error "BASE-KEY must be a non-empty string"))
  (unless
   (and (listp suffixes) (> (length suffixes) 0)) (error "SUFFIXES must be a non-empty list"))
  (let ((num-placeholders
         (- (length base-key) (length (replace-regexp-in-string "%s" "" base-key)))))
    (unless
     (= num-placeholders 2)
     (error "BASE-KEY must contain exactly one %%s placeholder, found %d" (/ num-placeholders 2))))
  (let ((result nil))
    (dolist
     (suffix suffixes)
     (unless
      (stringp suffix)
      (core-message-warning "Skipping non-string suffix: %s" suffix)
      (setq result (plist-put result (intern (concat ":" (format "%s" suffix))) nil))
      (cl-continue))
     (condition-case err
         (let ((value (git-utils-git-config-get (format base-key suffix))))
           (setq result (plist-put result (intern (concat ":" suffix)) value)))
       (error
        (core-message-warning
         "Failed to get config for suffix '%s': %s" suffix (error-message-string err))
        (setq result (plist-put result (intern (concat ":" suffix)) nil)))))
    result))

 (core-message-config "Git utility functions loaded"))
(provide 'git-utils)
;;; git-utils.el ends here
