;;; git-utils.el --- Git Utility Functions -*- lexical-binding: t -*-

;;; Commentary:
;;      Utility functions for git integration.
;;      Provides helper functions for Magit and Forge.
(require 'core-utils)
(require 'core-logging)
(core-utils-with-load-timing
 "git-utils.el"
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Magit Utility Functions
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  git-utils-magit-display-buffer-side
  (buffer)
  "Display BUFFER in side window sized to fit longest line."
  (let ((win-width
         (with-current-buffer
          buffer
          (save-excursion
           (goto-char (point-min))
           (let ((max-len 0))
             (while
              (re-search-forward
               "^\\(?:modified\\|new file\\|deleted\\|renamed\\)\\s-+\\(.+\\)$" nil t)
              (setq max-len (max max-len (+ 12 (length (match-string 1))))))
             (if (> max-len 0) (min (floor (* (frame-width) 0.8)) (max 60 (+ max-len 5))) 60))))))
    (display-buffer
     buffer `(display-buffer-in-side-window (side . right) (window-width . ,win-width)))))

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
 (defun
  user-git-issues (&optional repo)
  "List forge issues directly without showing the transient menu.
Optional REPO argument specifies which repository to list issues for."
  (interactive)
  (condition-case err
      (progn
       (require 'forge-topics) (unless (magit-gitdir) (user-error "Not in a git repository"))
       (let ((repository (or repo (forge-get-repository :tracked))))
         (forge-topics-setup-buffer repository nil :type 'issue)))
    (user-error
     (core-message-warning "%s" (error-message-string err)))
    (error
     (core-message-error "Failed to list issues: %s" (error-message-string err)))))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Git Config Utility Functions
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
Returns nil if git is not installed or no matches found."
  (when
   (git-utils--ensure-git-available)
   (let ((output
          (shell-command-to-string
           (format "git config --global --get-regexp '%s' 2>/dev/null" pattern))))
     (when (> (length output) 0) (split-string output "\n" t)))))

 (defun
  git-utils-git-config-get (key)
  "Get git config value for KEY using git config --global --get.
Returns the value as a string, or nil if not found or git not installed."
  (when
   (git-utils--ensure-git-available)
   (let ((output
          (shell-command-to-string (format "git config --global --get '%s' 2>/dev/null" key))))
     (when (> (length output) 0) (string-trim output)))))

 (defun
  git-utils-git-config-get-multiple (base-key suffixes)
  "Get multiple git config values for BASE-KEY with different SUFFIXES.
BASE-KEY should be a format string with one %s placeholder for the suffix.
SUFFIXES should be a list of suffix names.
Returns a plist with keyword versions of SUFFIXES as keys and config values as values.

Example:
  (git-utils-git-config-get-multiple \"emacs-forge.myhost.%s\" '(\"apihost\" \"webhost\" \"type\" \"user\"))
  => (:apihost \"api.example.com\" :webhost \"example.com\" :type \"gitlab\" :user \"john\")"
  (let ((result nil))
    (dolist
     (suffix suffixes)
     (let ((value (git-utils-git-config-get (format base-key suffix))))
       (setq result (plist-put result (intern (concat ":" suffix)) value))))
    result))

 (core-message-config "Git utility functions loaded"))
(provide 'git-utils)
;;; git-utils.el ends here
