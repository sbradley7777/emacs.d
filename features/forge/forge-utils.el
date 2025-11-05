;;; forge-utils.el --- Forge configuration utilities and diagnostics -*- lexical-binding: t -*-

;;; Commentary:
;; Utilities for working with forge hosts (GitHub, GitLab, etc.) including
;; diagnostics for viewing configured hosts and their authentication status.
(require 'core-logging)
(require 'core-utils)
(require 'forge-constants)
(require 'git-forge-config)
(require 'git-utils)
(core-utils-with-load-timing
 "forge-utils.el"
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Authinfo Parsing
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (defun
  forge-utils-parse-authinfo ()
  "Parse ~/.authinfo and return list of entries.
Each entry is a plist with :machine, :login, and :password keys.
Returns nil if file doesn't exist."
  (let ((authinfo-file (expand-file-name forge-authinfo-path)))
    (when
     (file-exists-p authinfo-file)
     (with-temp-buffer
      (insert-file-contents authinfo-file)
      (let ((entries '()))
        (goto-char (point-min))
        (while
         (not (eobp))
         (let ((line
                (buffer-substring-no-properties (line-beginning-position) (line-end-position))))
           (unless
            (or (string-match-p "^\\s-*$" line) (string-match-p "^\\s-*#" line))
            (let ((machine nil)
                  (login nil)
                  (password nil))
              (when
               (string-match "machine\\s-+\\([^ \t\n]+\\)" line)
               (setq machine (match-string 1 line)))
              (when
               (string-match "login\\s-+\\([^ \t\n]+\\)" line) (setq login (match-string 1 line)))
              (when
               (string-match "password\\s-+\\([^ \t\n]+\\)" line)
               (setq password (match-string 1 line)))
              (when
               (and machine login password)
               (push (list :machine machine :login login :password password) entries)))))
         (forward-line 1))
        (nreverse entries))))))

 (defun
  forge-utils-check-authinfo-for-host (host)
  "Check authentication status for HOST in ~/.authinfo.
HOST should be the API host (e.g., 'api.github.com', 'gitlab.com').
Returns one of:
  :authenticated - credentials found in ~/.authinfo
  :no-credentials - ~/.authinfo exists but no entry for this host
  :no-authinfo - ~/.authinfo file doesn't exist"
  (let ((authinfo-file (expand-file-name forge-authinfo-path)))
    (if
     (not (file-exists-p authinfo-file))
     :no-authinfo
     (let ((entries (forge-utils-parse-authinfo))
           (found nil))
       (dolist (entry entries) (when (string= (plist-get entry :machine) host) (setq found t)))
       (if found :authenticated :no-credentials)))))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Forge Host Diagnostics
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  forge-utils-diagnostics-show-hosts
  ()
  "Display all configured forge hosts and their authentication status.
Shows forge hosts from ~/.gitconfig along with their configuration details
and whether they have credentials configured in ~/.authinfo."
  (interactive)
  (core-message-plain "")
  (core-message-plain "=== Forge Host Diagnostics ===")
  (core-message-plain "")
  (let* ((hosts (git-forge-config-parse-hosts))
         (total-hosts (length hosts))
         (github-count 0)
         (gitlab-count 0)
         (authenticated-count 0))
    (if
     (zerop total-hosts)
     (core-message-warning "No forge hosts configured in ~/.gitconfig")
     (dolist
      (host-id hosts)
      (let* ((config (git-forge-config-parse-host-config host-id))
             (forge-type (plist-get config :type))
             (git-host (plist-get config :githost))
             (web-host (plist-get config :webhost))
             (api-host (plist-get config :apihost))
             (user (plist-get config :user))
             (auth-status (forge-utils-check-authinfo-for-host api-host)))
        (core-message-plain "Host: %s" host-id)
        (core-message-plain "  Type: %s" (or forge-type "unknown"))
        (when git-host (core-message-plain "  Git Host: %s" git-host))
        (when web-host (core-message-plain "  Web Host: %s" web-host))
        (when api-host (core-message-plain "  API Host: %s" api-host))
        (when user (core-message-plain "  User: %s" user))
        (cond
         ((eq auth-status :authenticated)
          (core-message-success "Authentication: ✓ Configured in ~/.authinfo")
          (setq authenticated-count (1+ authenticated-count)))
         ((eq auth-status :no-credentials)
          (core-message-warning "Authentication: ✗ No credentials in ~/.authinfo"))
         ((eq auth-status :no-authinfo)
          (core-message-warning "Authentication: ⚠️  ~/.authinfo file not found")))
        (core-message-plain "")
        (cond
         ((string= forge-type "github")
          (setq github-count (1+ github-count)))
         ((string= forge-type "gitlab")
          (setq gitlab-count (1+ gitlab-count))))))
     (core-message-plain "\n  === Total Number of Hosts ===")
     (when (> github-count 0) (core-message-plain "  GitHub hosts:   %d" github-count))
     (when (> gitlab-count 0) (core-message-plain "  GitLab hosts:   %d" gitlab-count))
     (core-message-plain "  ─────────────────────────────\n")
     (core-message-plain
      "  Total hosts:    %d (Authenticated hosts total:  %d)" total-hosts authenticated-count)
     (core-message-plain "")))))
(provide 'forge-utils)
;;; forge-utils.el ends here
