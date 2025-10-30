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
Returns list of host strings (e.g., (\"gitlab.example.com\" \"github.com\")).
Validates that extracted hostnames are properly formatted."
  (let ((lines (git-utils-git-config-get-regexp "^emacs-forge\\..*\\.apihost$"))
        (hosts nil))
    (when
     lines
     (dolist
      (line lines)
      (when
       (string-match "^emacs-forge\\.\\(.+\\)\\.apihost " line)
       (let ((host (match-string 1 line)))
         (if
          (git-utils--validate-hostname host)
          (push host hosts)
          (core-message-warning "Skipping invalid hostname in ~/.gitconfig: '%s'" host))))))
    (reverse hosts)))

 (defun
  forge-gitconfig-parse-config-for-host (host)
  "Parse forge configuration for HOST from ~/.gitconfig.
Returns plist with :githost, :apihost, :webhost, :type, :user keys.
Returns nil if HOST is invalid."
  (unless
   (and (stringp host) (not (string-empty-p host)))
   (core-message-warning "Invalid host parameter: %s" host)
   (cl-return-from forge-gitconfig-parse-config-for-host nil))
  (unless
   (git-utils--validate-hostname host)
   (core-message-warning "Host '%s' is not a valid hostname format" host)
   (cl-return-from forge-gitconfig-parse-config-for-host nil))
  (condition-case err
      (let ((config
             (git-utils-git-config-get-multiple
              (format "emacs-forge.%s.%%s" host) '("apihost" "webhost" "type" "user"))))
        (when
         (plist-get config :apihost)
         (unless
          (string-match-p "^[a-zA-Z0-9][-a-zA-Z0-9./]*[a-zA-Z0-9]$" (plist-get config :apihost))
          (core-message-warning
           "Invalid apihost format for %s: %s" host (plist-get config :apihost))))
        (when
         (plist-get config :webhost)
         (unless
          (git-utils--validate-hostname (plist-get config :webhost))
          (core-message-warning
           "Invalid webhost format for %s: %s" host (plist-get config :webhost))))
        (plist-put config :githost host))
    (error
     (core-message-error
      "Failed to parse config for host '%s': %s" host (error-message-string err))
     nil)))

 (defun
  forge-gitconfig-forge-type-to-class (type)
  "Convert forge TYPE string to repository class symbol.
TYPE should be one of: gitlab, github, gitea, gogs, bitbucket (case-insensitive).
Returns the corresponding forge-*-repository symbol, or nil if unknown.
Logs a warning if TYPE is unknown or invalid."
  (unless
   (and (stringp type) (not (string-empty-p type)))
   (core-message-warning "Invalid forge type (must be non-empty string): %s" type)
   (cl-return-from forge-gitconfig-forge-type-to-class nil))
  (let ((normalized-type (downcase type)))
    (pcase normalized-type
      ("gitlab" 'forge-gitlab-repository)
      ("github" 'forge-github-repository)
      ("gitea" 'forge-gitea-repository)
      ("gogs" 'forge-gogs-repository)
      ("bitbucket" 'forge-bitbucket-repository)
      (_
       (core-message-warning
        "Unknown forge type '%s'. Supported types: gitlab, github, gitea, gogs, bitbucket" type)
       nil))))

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
       (unless
        (require 'forge nil t)
        (core-message-error
         "Forge package not available. Install it with: M-x package-install RET forge")
        (cl-return-from forge-gitconfig-populate-forge-alist-from-gitconfig nil))
       (unless
        (boundp 'forge-alist)
        (core-message-error
         "forge-alist variable not defined. Ensure forge is properly loaded")
        (cl-return-from forge-gitconfig-populate-forge-alist-from-gitconfig nil))
       (unless
        (fboundp 'magit-get)
        (core-message-warning
         "magit-get function not available. Username configuration will be skipped"))
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
              ((not config)
               (core-message-warning "Failed to parse config for host '%s', skipping" host))
              ((not (and githost apihost webhost type))
               (core-message-warning
                "Skipping incomplete [emacs-forge \"%s\"] entry in ~/.gitconfig (missing required fields)"
                (or githost host)))
              (t
               (unless
                (assoc githost forge-alist)
                (let ((repo-class (forge-gitconfig-forge-type-to-class type)))
                  (when
                   repo-class
                   (condition-case inner-err
                       (progn
                        (push (list githost apihost webhost repo-class) forge-alist)
                        (setq added-count (1+ added-count))
                        (core-message-config "Added forge host from ~/.gitconfig: %s" githost))
                     (error
                      (core-message-error
                       "Failed to add forge host '%s': %s"
                       githost
                       (error-message-string inner-err)))))))
               (when
                (and user (fboundp 'magit-get) (fboundp 'magit-set) type apihost)
                (condition-case inner-err
                    (let ((git-var (format "%s.%s.user" type apihost)))
                      (unless
                       (magit-get git-var)
                       (magit-set user git-var)
                       (setq user-count (1+ user-count))
                       (core-message-config "Set %s = %s" git-var user)))
                  (error
                   (core-message-warning
                    "Failed to set username for %s: %s"
                    host
                    (error-message-string inner-err)))))))))
          (when
           (> added-count 0)
           (core-message-success
            "Added %d forge host%s from ~/.gitconfig" added-count (if (= added-count 1) "" "s")))
          (when
           (> user-count 0)
           (core-message-success
            "Configured %d username%s" user-count (if (= user-count 1) "" "s")))
          (when
           (and (= added-count 0) (= user-count 0) hosts)
           (core-message-info "All forge hosts from ~/.gitconfig already configured")))))
    (error
     (core-message-error
      "Failed to read forge config from ~/.gitconfig: %s" (error-message-string err)))))

 (core-message-config "Forge gitconfig utilities loaded"))
(provide 'forge-gitconfig)
;;; forge-gitconfig.el ends here
