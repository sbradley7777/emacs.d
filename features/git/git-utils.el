;;; git-utils.el --- Git Utility Functions -*- lexical-binding: t -*-
;;; Commentary:
;;      Utility functions for git integration.
;;      Provides helper functions for git repository detection and configuration.

;;; Code:
(require 'core-utils)
(require 'core-logging)
(require 'vc-git)
(require 'core-process-utils)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar
 git-utils--git-available-cache 'unchecked
 "Cached result of git command availability check.
Value is t if git is available, nil if not available, and \\='unchecked if not yet checked.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 git-utils-find-repository-root (&optional directory)
 "Find git repository root using built-in vc-git.
DIRECTORY is the starting directory to search from (defaults to current directory).
Returns the repository root path, or nil if not in a git repository."
 (when-let ((root (vc-git-root (or directory default-directory))))
   (expand-file-name root)))

(defun
 git-format-repository-display (repo-root)
 "Format REPO-ROOT for display as \\='name (abbreviated-path)\\='.
Extracts repository name from directory path.
Example: \\='glocktopography (~/gitlab/glocktopography/)\\='."
 (when
  repo-root
  (let ((name (core-utils-extract-directory-name repo-root)))
    (format "%s (%s)" name (abbreviate-file-name repo-root)))))

(defun
 git--utils-validate-config-key (key)
 "Validate that KEY is a non-empty string suitable for git config.
Returns t if valid, nil otherwise.  Logs warning if invalid.
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
 git--utils-ensure-git-available ()
 "Check if git command is available.  Return t if available, nil otherwise.
Logs a warning if git is not found.  Caches result to avoid redundant checks."
 (if
  (eq git-utils--git-available-cache 'unchecked)
  ;; First check - perform actual check and cache result
  (progn
   (setq git-utils--git-available-cache (core-utils-check-command-in-path "git"))
   git-utils--git-available-cache)
  ;; Already checked - return cached result (no logging)
  git-utils--git-available-cache))

(defun
 git-utils-git-config-get-regexp (pattern)
 "Get git config values matching PATTERN using git config --global --get-regexp.
Returns list of strings, one per matching config line.
Returns nil if git is not installed, PATTERN is invalid, or no matches found."
 (when
  (and (git--utils-ensure-git-available) (git--utils-validate-config-key pattern))
  (when-let ((output (core-process-run-sync "git" t "config" "--global" "--get-regexp" pattern)))
    (when (> (length output) 0) (split-string output "\n" t)))))

(defun
 git-utils-git-config-get (key)
 "Get git config value for KEY using git config --global --get.
Returns the value as a string, or nil if not found, KEY is invalid, or git not installed."
 (when
  (and (git--utils-ensure-git-available) (git--utils-validate-config-key key))
  (core-process-run-sync "git" t "config" "--global" "--get" key)))

(defun
 git-utils-git-config-get-multiple (base-key suffixes)
 "Get multiple git config values for BASE-KEY with different SUFFIXES.
BASE-KEY should be a format string with one %s placeholder for the suffix.
SUFFIXES should be a list of suffix names.
Returns a plist with keyword versions of SUFFIXES as keys and config values as values.

Example:
  (git-utils-git-config-get-multiple \"emacs-forge.myhost.%s\" \\='(\"apihost\" \"webhost\" \"type\" \"user\"))
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
    (if
     (not (stringp suffix))
     (progn
      (core-message-warning "Skipping non-string suffix: %s" suffix)
      (setq result (plist-put result (intern (concat ":" (format "%s" suffix))) nil)))
     (condition-case err
         (let ((value (git-utils-git-config-get (format base-key suffix))))
           (setq result (plist-put result (intern (concat ":" suffix)) value)))
       (error
        (core-message-warning
         "Failed to get config for suffix '%s': %s" suffix (error-message-string err))
        (setq result (plist-put result (intern (concat ":" suffix)) nil))))))
   result))

(defun
 git-utils-extract-host-from-url (url)
 "Extract the host portion from a git remote URL.
URL can be in SSH, HTTPS, or git protocol format.
Returns the hostname (e.g., \\='github.com\\=') or nil if unrecognized format.

Supported formats:
  - SSH: git@github.com:user/repo.git
  - HTTPS: https://github.com/user/repo.git
  - Git protocol: git://github.com/user/repo.git"
 (when
  (and (stringp url) (not (string-empty-p url)))
  (cond
   ;; SSH format: git@github.com:user/repo.git
   ((string-match "^git@\\([^:]+\\):" url)
    (match-string 1 url))
   ;; HTTPS format: https://github.com/user/repo.git
   ((string-match "^https?://\\([^/]+\\)" url)
    (match-string 1 url))
   ;; Git protocol: git://github.com/user/repo.git
   ((string-match "^git://\\([^/]+\\)" url)
    (match-string 1 url))
   (t
    nil))))

(core-message-config "Git utility functions loaded")
(provide 'git-utils)
;;; git-utils.el ends here
