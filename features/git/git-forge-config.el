;;; git-forge-config.el --- Forge Configuration from Git Config -*- lexical-binding: t -*-
;;; Commentary:
;;      Functions to read and populate forge-alist from ~/.gitconfig.
;;      Supports GitHub, GitLab, Gitea, Gogs, and Bitbucket forge hosts.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;      AUTOMATIC FEATURES:
;;        1. Populates forge-alist from [emacs-forge] sections in ~/.gitconfig on startup
;;        2. Auto-configures usernames in repository-local .git/config when opening files
;;        3. Ensures each repository only gets username config for its specific forge host
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;      WORKFLOW:
;;        - On Emacs startup: Reads ~/.gitconfig and populates forge-alist
;;        - When opening a file in a git repo: Detects forge host and sets username in local .git/config
;;        - Before forge-pull: Ensures username is configured (backup safety check)

;;; Code:
(require 'core-utils)
(require 'core-logging)
(require 'git-utils)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 git-forge-config-parse-hosts ()
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
         (core-utils-validate-hostname host)
         (push host hosts)
         (core-message-warning "Skipping invalid hostname in ~/.gitconfig: '%s'" host))))))
   (reverse hosts)))

(defun
 git-forge-config-parse-host-config (host)
 "Parse forge configuration for HOST from ~/.gitconfig.
Returns plist with :githost, :apihost, :webhost, :type, :user keys.
Returns nil if HOST is invalid."
 (unless
  (core-validate-non-empty-string host "Host parameter")
  (cl-return-from git-forge-config-parse-host-config nil))
 (unless
  (core-utils-validate-hostname host)
  (core-message-warning "Host '%s' is not a valid hostname format" host)
  (cl-return-from git-forge-config-parse-host-config nil))
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
         (core-utils-validate-hostname (plist-get config :webhost))
         (core-message-warning
          "Invalid webhost format for %s: %s" host (plist-get config :webhost))))
       (plist-put config :githost host))
   (error
    (core-message-error "Failed to parse config for host '%s': %s" host (error-message-string err))
    nil)))

(defun
 git-forge-config-type-to-class (type)
 "Convert forge TYPE string to repository class symbol.
TYPE should be one of: gitlab, github, gitea, gogs, bitbucket (case-insensitive).
Returns the corresponding forge-*-repository symbol, or nil if unknown.
Logs a warning if TYPE is unknown or invalid."
 (unless
  (and (stringp type) (not (string-empty-p type)))
  (core-message-warning "Invalid forge type (must be non-empty string): %s" type)
  (cl-return-from git-forge-config-type-to-class nil))
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
 git-populate-forge-alist ()
 "Populate forge-alist from [emacs-forge] sections in ~/.gitconfig.

This function reads custom forge host configurations from ~/.gitconfig
and adds them to forge-alist so that Forge can work with custom instances.

Only adds hosts that are not already present in forge-alist to avoid duplicates.
Skips entries with missing required fields (apihost, webhost, or type).

Note: Usernames are configured per-repository when files are opened,
not globally, to keep .git/config files clean."
 (interactive)
 (condition-case err
     (progn
      (unless
       (require 'forge nil t)
       (core-message-error
        "Forge package not available.  Install it with: M-x package-install RET forge")
       (cl-return-from git-populate-forge-alist nil))
      (unless
       (boundp 'forge-alist)
       (core-message-error
        "Forge-alist variable not defined.  Ensure forge is properly loaded")
       (cl-return-from git-populate-forge-alist nil))
      (let ((hosts (git-forge-config-parse-hosts))
            (added-count 0))
        (if
         (null hosts) (core-message-info "No [emacs-forge] sections found in ~/.gitconfig")
         (dolist
          (host hosts)
          (let* ((config (git-forge-config-parse-host-config host))
                 (githost (plist-get config :githost))
                 (apihost (plist-get config :apihost))
                 (webhost (plist-get config :webhost))
                 (type (plist-get config :type)))
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
               (let ((repo-class (git-forge-config-type-to-class type)))
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
                      (error-message-string inner-err)))))))))))
         (when
          (> added-count 0)
          (core-message-success
           "Added %d forge host%s from ~/.gitconfig" added-count (if (= added-count 1) "" "s")))
         (when
          (and (= added-count 0) hosts)
          (core-message-info "All forge hosts from ~/.gitconfig already configured")))))
   (error
    (core-message-error
     "Failed to read forge config from ~/.gitconfig: %s" (error-message-string err)))))

(defun
 git-forge-config-get-repo-host ()
 "Get the forge host for the current git repository.
Returns the host portion from the remote.origin.url, or nil if not in a git repo.
For example: \\='github.com\\=' or \\='gitlab.example.com\\='."
 (when
  (and (git-utils-find-repository-root) (fboundp 'magit-get))
  (when-let ((url (magit-get "remote.origin.url")))
    (git-utils-extract-host-from-url url))))

(defun
 git-forge-config-set-repo-username ()
 "Set username in local .git/config for the current repository's forge host.
Only sets username if:
1. We're in a git repository
2. The repository's host matches one of our [emacs-forge] configurations
3. The username is not already set in local config
This ensures each repository only gets username config for its own host."
 (interactive)
 (when
  (and (fboundp 'magit-get) (fboundp 'magit-set))
  (let ((repo-host (git-forge-config-get-repo-host)))
    (when
     repo-host
     (let* ((config (git-forge-config-parse-host-config repo-host))
            (apihost (plist-get config :apihost))
            (type (plist-get config :type))
            (user (plist-get config :user)))
       (when
        (and user type apihost)
        (let ((git-var (format "%s.%s.user" type apihost)))
          (unless
           (magit-get git-var)
           (condition-case err
               (progn
                (magit-set user git-var) (core-message-config "Set local %s = %s" git-var user))
             (error
              (core-message-warning
               "Failed to set local username: %s" (error-message-string err))))))))))))

(defun
 git--forge-config-setup-repo-on-file-open ()
 "Hook function to set repository username when opening files in git repos.
Called automatically via `find-file-hook'.
Loads Magit if needed, then sets username for the repository's forge host."
 (when
  (buffer-file-name)
  ;; Check if we're in a git repository first
  (when
   (git-utils-find-repository-root)
   ;; Load magit if not already loaded
   (unless (fboundp 'magit-get) (require 'magit nil t))
   ;; Set username if magit functions are available
   (when (and (fboundp 'magit-get) (fboundp 'magit-set)) (git-forge-config-set-repo-username)))))

;; Auto-configure username when opening files in git repositories
;; Hook is added immediately, but function checks if Magit is loaded before running
(add-hook 'find-file-hook #'git--forge-config-setup-repo-on-file-open)

;; Also ensure username is set before Forge operations
(defun
 git-forge-config-before-forge-pull ()
 "Ensure repository username is configured before forge-pull.
This is called as advice before forge-pull to ensure username is set."
 (when
  (and (git-utils-find-repository-root) (fboundp 'magit-get) (fboundp 'magit-set))
  (git-forge-config-set-repo-username)))

(add-hook 'find-file-hook #'git--forge-config-setup-repo-on-file-open)

(with-eval-after-load 'forge (advice-add 'forge-pull :before #'git-forge-config-before-forge-pull))

(core-message-config "Git forge configuration utilities loaded")
(provide 'git-forge-config)
;;; git-forge-config.el ends here
