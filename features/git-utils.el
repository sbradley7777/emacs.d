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
 ;; Forge Configuration from Git Config
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; These functions read [emacs-forge "HOST"] sections from ~/.gitconfig to populate forge-alist.
 ;;
 ;; Example ~/.gitconfig entries:
 ;;
 ;;   [emacs-forge "gitlab.example.com"]
 ;;       apihost = gitlab.example.com/api/v4
 ;;       webhost = gitlab.example.com
 ;;       type = gitlab
 ;;       user = YOUR_USERNAME
 ;;
 ;;   [emacs-forge "github.enterprise.com"]
 ;;       apihost = github.enterprise.com/api/v3
 ;;       webhost = github.enterprise.com
 ;;       type = github
 ;;       user = YOUR_USERNAME
 ;;
 ;; This configuration is read automatically when Forge loads (see git-config.el).
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Git Config Utility Functions
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  git-utils-git-config-get-regexp (pattern)
  "Get git config values matching PATTERN using git config --global --get-regexp.
Returns list of strings, one per matching config line.
Returns nil if git is not installed or no matches found."
  (if
   (not (core-utils-check-command-in-path "git"))
   (progn (core-message-warning "git command not found") nil)
   (let ((output
          (shell-command-to-string
           (format "git config --global --get-regexp '%s' 2>/dev/null" pattern))))
     (when (> (length output) 0) (split-string output "\n" t)))))

 (defun
  git-utils-git-config-get (key)
  "Get git config value for KEY using git config --global --get.
Returns the value as a string, or nil if not found or git not installed."
  (if
   (not (core-utils-check-command-in-path "git"))
   (progn (core-message-warning "git command not found") nil)
   (let ((output
          (shell-command-to-string (format "git config --global --get '%s' 2>/dev/null" key))))
     (when (> (length output) 0) (string-trim output)))))

 (defun
  git-utils-parse-forge-hosts-from-gitconfig ()
  "Parse host names from [emacs-forge] sections in ~/.gitconfig.
Returns list of host strings (e.g., (\"gitlab.example.com\" \"github.com\"))."
  (let ((lines (git-utils-git-config-get-regexp "^emacs-forge\\..*\\.apihost$"))
        (hosts nil))
    (when
     lines
     (dolist
      (line lines)
      (when
       (string-match "^emacs-forge\\.\\(.+\\)\\.apihost " line)
       (push (match-string 1 line) hosts))))
    (reverse hosts)))

 (defun
  git-utils-parse-forge-config-for-host (host)
  "Parse forge configuration for HOST from ~/.gitconfig.
Returns plist with :githost, :apihost, :webhost, :type, :user keys."
  (let ((apihost (git-utils-git-config-get (format "emacs-forge.%s.apihost" host)))
        (webhost (git-utils-git-config-get (format "emacs-forge.%s.webhost" host)))
        (type (git-utils-git-config-get (format "emacs-forge.%s.type" host)))
        (user (git-utils-git-config-get (format "emacs-forge.%s.user" host))))
    (list :githost host :apihost apihost :webhost webhost :type type :user user)))

 (defun
  git-utils-forge-type-to-class (type)
  "Convert forge TYPE string to repository class symbol.
TYPE should be one of: gitlab, github, gitea, gogs, bitbucket.
Returns the corresponding forge-*-repository symbol, or nil if unknown."
  (pcase type
    ("gitlab" 'forge-gitlab-repository)
    ("github" 'forge-github-repository)
    ("gitea" 'forge-gitea-repository)
    ("gogs" 'forge-gogs-repository)
    ("bitbucket" 'forge-bitbucket-repository)
    (_ nil)))

 (defun
  git-utils-populate-forge-alist-from-gitconfig ()
  "Populate forge-alist from [emacs-forge] sections in ~/.gitconfig.

This function reads custom forge host configurations from ~/.gitconfig
and adds them to forge-alist so that Forge can work with custom instances.

Also configures usernames per host using git config variables that ghub reads.

Only adds hosts that are not already present in forge-alist to avoid duplicates.
Skips entries with missing required fields (apihost, webhost, or type)."
  (interactive)
  (condition-case err
      (progn
       (require 'forge nil t)
       (let ((hosts (git-utils-parse-forge-hosts-from-gitconfig))
             (added-count 0)
             (user-count 0))
         (if
          (null hosts) (core-message-info "No [emacs-forge] sections found in ~/.gitconfig")
          (dolist
           (host hosts)
           (let* ((config (git-utils-parse-forge-config-for-host host))
                  (githost (plist-get config :githost))
                  (apihost (plist-get config :apihost))
                  (webhost (plist-get config :webhost))
                  (type (plist-get config :type))
                  (user (plist-get config :user)))
             (cond
              ((not (and githost apihost webhost type))
               (core-message-warning
                "Skipping incomplete [emacs-forge \"%s\"] entry in ~/.gitconfig"
                (or githost "unknown")))
              (t
               (unless
                (assoc githost forge-alist)
                (let ((repo-class (git-utils-forge-type-to-class type)))
                  (if
                   repo-class
                   (progn
                    (push (list githost apihost webhost repo-class) forge-alist)
                    (setq added-count (1+ added-count))
                    (core-message-config "Added forge host from ~/.gitconfig: %s" githost))
                   (core-message-warning "Unknown forge type '%s' for %s" type githost))))
               (when
                user
                (let ((git-var (format "%s.%s.user" type apihost)))
                  (unless
                   (magit-get git-var)
                   (magit-set user git-var)
                   (setq user-count (1+ user-count))
                   (core-message-config "Set %s = %s" git-var user))))))))
          (when
           (> added-count 0)
           (core-message-success
            "Added %d forge host%s from ~/.gitconfig" added-count (if (= added-count 1) "" "s")))
          (when
           (> user-count 0)
           (core-message-success
            "Configured %d username%s" user-count (if (= user-count 1) "" "s")))
          (when
           (and (= added-count 0) (= user-count 0))
           (core-message-info "All forge hosts from ~/.gitconfig already configured")))))
    (error
     (core-message-error
      "Failed to read forge config from ~/.gitconfig: %s" (error-message-string err)))))

 (core-message-config "Git utility functions loaded"))
(provide 'git-utils)
;;; git-utils.el ends here
