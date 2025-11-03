;;; git-auto-sync.el --- Automatic Git and Forge Synchronization -*- lexical-binding: t -*-

;;; Commentary:
;; WHAT: Automatic synchronization of Git and Forge data when opening repository files
;; WHY:  Keeps Git refs and Forge metadata up-to-date without manual intervention
;; PROVIDES: Auto-fetch for Magit, auto-pull for Forge, once per repository per session
;;
;; Features:
;; - Automatically fetches Git data (branches, tags, commits) via Magit
;; - Automatically pulls Forge data (issues, PRs, comments) via Forge API
;; - Runs once per repository per Emacs session
;; - Modular design allows independent use of Magit or Forge sync
(require 'core-utils)
(require 'core-logging)
(require 'git-utils)
(core-utils-with-load-timing
 "git-auto-sync.el"
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Shared State and Utilities
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defvar
  git-auto-sync--synced-repositories-table (make-hash-table :test 'equal)
  "Hash table tracking repositories synced this session.
Keys are repository root paths, values are timestamps.")
 (defun
  git-auto-sync--is-repository-synced-p (repo-root)
  "Check if REPO-ROOT has been synced this session.
Returns the timestamp if synced, nil otherwise."
  (gethash repo-root git-auto-sync--synced-repositories-table))
 (defun
  git-auto-sync--mark-repository-synced
  (repo-root)
  "Mark REPO-ROOT as synced with current timestamp."
  (puthash repo-root (current-time) git-auto-sync--synced-repositories-table))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Magit Auto-Sync
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Note: Magit fetch runs asynchronously, but we don't show a completion message because:
 ;; - Magit already displays "Fetching..." and "Fetching...done" in the mode line
 ;; - Detecting completion reliably is complex (magit-process-finish-hook fires for ALL processes)
 ;; - Users can check magit-status to see the results when needed
 (defun
  git-auto-sync-magit-fetch (repo-root)
  "Fetch Git data for REPO-ROOT using Magit.
Loads Magit if not already loaded and fetches all remotes."
  (require 'magit nil t)
  (when
   (fboundp 'magit-fetch-all)
   (core-message-info "Fetching Git data for: %s" repo-root)
   (magit-fetch-all nil)))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Forge Auto-Sync
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  git-auto-sync-forge-pull (repo-root)
  "Fetch Forge data for REPO-ROOT using Forge.
Loads Forge if not already loaded and fetches issues/PRs from the forge API.

Note: We use 'Fetching' in the message for consistency with git-auto-sync-magit-fetch,
even though the underlying function is named forge-pull. The operation is semantically
a fetch (retrieves remote data without modifying local state), not a pull (fetch + merge)."
  (require 'forge nil t)
  (when
   (fboundp 'forge-pull) (core-message-info "Fetching Forge data for: %s" repo-root) (forge-pull)))

 ;; Forge Completion Detection
 ;; Forge doesn't provide a post-pull hook, so we use :around advice on forge--pull
 ;; to inject a callback that shows a completion message. This works because forge--pull
 ;; accepts an optional callback parameter that gets called when the async operation completes.
 (defun
  git-auto-sync--around-forge-pull-advice (orig-fun repo &optional callback since)
  "Advice to wrap forge--pull and inject completion detection.
ORIG-FUN is the original forge--pull function.
REPO, CALLBACK, and SINCE are the original forge--pull arguments.

This advice wraps the callback to show a success message when Forge completes
fetching and storing data, but only for repositories we initiated sync for."
  (let ((repo-root (git-utils-find-repository-root))
        (original-callback callback))
    (if
     (and repo-root (git-auto-sync--is-repository-synced-p repo-root))
     ;; Inject our wrapped callback that shows completion message
     (funcall
      orig-fun repo
      (lambda
       ()
       (when original-callback (funcall original-callback))
       (core-message-success "Forge data fetched for: %s" repo-root))
      since)
     ;; Pass through unchanged for non-auto-synced calls
     (funcall orig-fun repo callback since))))
 (with-eval-after-load
  'forge (advice-add 'forge--pull :around #'git-auto-sync--around-forge-pull-advice))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Combined Auto-Sync
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  git-auto-sync-repository-once ()
  "Sync both Magit and Forge data once per repository when first file is opened.
Fetches Git refs via Magit and pulls Forge metadata via Forge API.
Runs only once per repository per Emacs session."
  (when-let ((repo-root (git-utils-find-repository-root)))
    (unless
     (git-auto-sync--is-repository-synced-p repo-root)
     (git-auto-sync--mark-repository-synced repo-root)
     (core-message-info "Initiated sync for repository: %s" repo-root)
     (git-auto-sync-magit-fetch repo-root)
     (git-auto-sync-forge-pull repo-root))))
 (add-hook 'find-file-hook #'git-auto-sync-repository-once)
 (core-message-config
  "Git and Forge auto-sync configured to run once per repository on first file open"))
(provide 'git-auto-sync)
;;; git-auto-sync.el ends here
