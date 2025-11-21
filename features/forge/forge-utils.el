;;; forge-utils.el --- Forge configuration utilities and diagnostics -*- lexical-binding: t -*-
;;; Commentary:
;; Utilities for working with forge hosts (GitHub, GitLab, etc.) including
;; diagnostics for viewing configured hosts and their authentication status,
;; and TRAMP support for remote repository operations.
;;
;; Authentication checking uses Emacs' built-in `auth-source' library,
;; which supports:
;;   - ~/.authinfo.gpg (encrypted, recommended)
;;   - ~/.authinfo (plaintext)
;;   - ~/.netrc
;;   - macOS Keychain
;;   - Secret Service API (Linux)

;;; Code:
(require 'core-logging)
(require 'core-utils)
(require 'forge-constants)
(require 'git-forge-config)
(require 'git-utils)
(require 'auth-source)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 forge-utils-parse-authinfo ()
 "Parse authentication sources and return list of entries.
Each entry is a plist with :machine, :login, and :password keys.
Uses `auth-source' to read from ~/.authinfo, ~/.authinfo.gpg, or configured backends.
Returns nil if no auth sources are configured."
 (let ((entries '())
       (sources (auth-source-search :max 10000)))
   (dolist
    (source sources)
    (let ((machine (plist-get source :host))
          (login (plist-get source :user))
          (secret (plist-get source :secret)))
      (when
       (and machine login secret)
       (let ((password (if (functionp secret) (funcall secret) secret)))
         (push (list :machine machine :login login :password password) entries)))))
   (nreverse entries)))

(defun
 forge-utils-check-authinfo-for-host (host)
 "Check authentication status for HOST in authentication sources.
HOST should be the API host (e.g., \\='api.github.com\\=', \\='gitlab.com\\=').
Returns one of:
  :authenticated - credentials found in auth sources
  :no-credentials - auth sources exist but no entry for this host
  :no-authinfo - no auth sources configured"
 (if
  (null auth-sources)
  :no-authinfo
  (let ((found (auth-source-search :host host :max 1)))
    (if found :authenticated :no-credentials))))

(defun
 forge-utils-diagnostics-show-hosts ()
 "Display all configured forge hosts and their authentication status.
Shows forge hosts from ~/.gitconfig along with their configuration details
and whether they have credentials configured in ~/.authinfo."
 (interactive)
 (let* ((hosts (git-forge-config-parse-hosts))
        (total-hosts (length hosts))
        (lines nil)
        (github-count 0)
        (gitlab-count 0)
        (authenticated-count 0)
        (missing-creds-count 0)
        (no-authinfo-count 0))
   (if
    (zerop total-hosts)
    (core-message-diagnostic
     "Forge Host Diagnostics" (list "⚠️  No forge hosts configured in ~/.gitconfig"))
    (dolist
     (host-id hosts)
     (let* ((config (git-forge-config-parse-host-config host-id))
            (forge-type (plist-get config :type))
            (api-host (plist-get config :apihost))
            (user (plist-get config :user))
            (auth-status (forge-utils-check-authinfo-for-host api-host)))
       (push (format "%s (%s)" host-id (capitalize (or forge-type "unknown"))) lines)
       (when
        (and user api-host (not (string= host-id api-host)))
        (push (format "  User: %s | API: %s" user api-host) lines))
       (when
        (and user (or (not api-host) (string= host-id api-host)))
        (push (format "  User: %s" user) lines))
       (cond
        ((eq auth-status :authenticated)
         (push "  ✅  Authenticated" lines)
         (setq authenticated-count (1+ authenticated-count)))
        ((eq auth-status :no-credentials)
         (push "  ⚠️  No credentials in ~/.authinfo" lines)
         (setq missing-creds-count (1+ missing-creds-count)))
        ((eq auth-status :no-authinfo)
         (push "  ❌  ~/.authinfo file not found" lines)
         (setq no-authinfo-count (1+ no-authinfo-count))))
       (cond
        ((string= forge-type "github")
         (setq github-count (1+ github-count)))
        ((string= forge-type "gitlab")
         (setq gitlab-count (1+ gitlab-count)))))))
   (push " " lines)
   (push "=== Summary ===" lines)
   (let ((format-str "%-22s"))
     (when
      (> authenticated-count 0)
      (push (format (concat "✅  " format-str " %d") "Authenticated" authenticated-count) lines))
     (when
      (> missing-creds-count 0)
      (push
       (format (concat "⚠️  " format-str " %d") "Missing credentials" missing-creds-count) lines))
     (when
      (> no-authinfo-count 0)
      (push
       (format (concat "❌  " format-str " %d") "Without ~/.authinfo" no-authinfo-count) lines))
     (let ((type-summary
            (string-join
             (delq
              nil
              (list
               (when (> github-count 0) (format "%d GitHub" github-count))
               (when (> gitlab-count 0) (format "%d GitLab" gitlab-count))))
             ", ")))
       (push
        (format (concat "ℹ️  " format-str " %d (%s)") "Total hosts" total-hosts type-summary)
        lines)))
   (core-message-diagnostic "Forge Host Diagnostics" (nreverse lines))))

(defun
 forge-utils--ghub-use-magit-get (orig-fun var)
 "Advice for ghub--git-get to delegate to magit-get for remote repositories.
ORIG-FUN is the original ghub--git-get function.
VAR is the git config variable to read.

When `default-directory' is remote (TRAMP), use magit-get which handles TRAMP
via `process-file'.  For local directories, use original ghub implementation."
 (if
  (core-utils-is-remote-file)
  ;; Remote: use magit-get (handles TRAMP)
  (progn (require 'magit-git nil t) (when (fboundp 'magit-get) (magit-get var)))
  ;; Local: use original ghub implementation
  (funcall orig-fun var)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(with-eval-after-load
 'ghub
 (advice-add 'ghub--git-get :around #'forge-utils--ghub-use-magit-get)
 (core-message-config "Forge TRAMP support configured"))
(provide 'forge-utils)
;;; forge-utils.el ends here
