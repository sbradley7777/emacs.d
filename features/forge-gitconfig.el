;;; forge-gitconfig.el --- Forge Configuration from Git Config -*- lexical-binding: t -*-

;;; Commentary:
;;      Functions to read and populate forge-alist from ~/.gitconfig.
;;      Supports GitHub, GitLab, Gitea, Gogs, and Bitbucket forge hosts.
(require 'core-utils)
(require 'core-logging)
(require 'git-utils)
(core-utils-with-load-timing
 "forge-gitconfig.el"
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
 ;; Forge Host Parsing
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  forge-gitconfig-parse-hosts-from-gitconfig ()
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
  forge-gitconfig-parse-config-for-host (host)
  "Parse forge configuration for HOST from ~/.gitconfig.
Returns plist with :githost, :apihost, :webhost, :type, :user keys."
  (let ((config
         (git-utils-git-config-get-multiple
          (format "emacs-forge.%s.%%s" host) '("apihost" "webhost" "type" "user"))))
    (plist-put config :githost host)))

 (defun
  forge-gitconfig-forge-type-to-class (type)
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
  forge-gitconfig-populate-forge-alist-from-gitconfig ()
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
       (let ((hosts (forge-gitconfig-parse-hosts-from-gitconfig))
             (added-count 0)
             (user-count 0))
         (if
          (null hosts) (core-message-info "No [emacs-forge] sections found in ~/.gitconfig")
          (dolist
           (host hosts)
           (let* ((config (forge-gitconfig-parse-config-for-host host))
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
                (let ((repo-class (forge-gitconfig-forge-type-to-class type)))
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

 (core-message-config "Forge gitconfig utilities loaded"))
(provide 'forge-gitconfig)
;;; forge-gitconfig.el ends here
