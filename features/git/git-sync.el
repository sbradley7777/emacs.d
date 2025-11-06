;;; git-sync.el --- Automatic Git and Forge Synchronization -*- lexical-binding: t -*-

;;; Commentary:
;; WHAT: Automatic and manual synchronization of Git and Forge data
;; WHY:  Keeps Git refs and Forge metadata up-to-date
;; PROVIDES: Auto-fetch for Magit, auto-pull for Forge, once per repository per session
;;           Manual sync command for on-demand updates
;;
;; Features:
;; - Automatically fetches Git data (branches, tags, commits) via Magit
;; - Automatically pulls Forge data (issues, PRs, comments) via Forge API
;; - Auto-sync runs once per repository per Emacs session
;; - Manual sync command (git-sync-repository) for on-demand updates
;; - Modular design allows independent use of Magit or Forge sync
(require 'core-utils)
(require 'core-logging)
(require 'git-utils)
(core-utils-with-load-timing
 "git-sync.el"
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
 (defun
  git-auto-sync-magit-fetch (repo-root)
  "Fetch Git data for REPO-ROOT using Magit.
Loads Magit if not already loaded and fetches all remotes."
  (require 'magit nil t)
  (when
   (fboundp 'magit-fetch-all)
   (core-message-info
    "Fetching magit git data for project: %s" (git-utils-format-repository-display repo-root))
   (magit-fetch-all nil)))

 ;; Magit Completion Detection
 ;; Magit doesn't provide a post-fetch hook, so we use :before advice on magit-process-sentinel
 ;; to detect when git fetch processes complete. We check the process command to identify fetch
 ;; operations and show completion messages only for repositories we initiated sync for.
 (defun
  git-auto-sync--before-magit-sentinel-advice (process event)
  "Advice to detect Magit fetch completion and show status message.
PROCESS is the git process that finished.
EVENT is the event string describing how the process finished.

This advice detects fetch completion by examining the process command,
but only shows messages for repositories we initiated sync for."
  (when
   (memq (process-status process) '(exit signal))
   (let* ((command (process-command process))
          (default-dir (process-get process 'default-dir))
          (exit-code (process-exit-status process)))
     ;; Only show message if this is a fetch command for a synced repository
     (when
      (and command (member "fetch" command) default-dir)
      ;; Find the repository root from the process's default-dir
      (let* ((process-dir (file-name-as-directory (expand-file-name default-dir)))
             (repo-root
              (let ((default-directory process-dir))
                (git-utils-find-repository-root))))
        (when
         (and repo-root (git-auto-sync--is-repository-synced-p repo-root))
         (if
          (zerop exit-code)
          (core-message-success
           "Fetched magit git data for project: %s"
           (git-utils-format-repository-display repo-root))
          (core-message-error
           "Failed to fetch magit git data for project: %s"
           (git-utils-format-repository-display repo-root)))))))))
 (with-eval-after-load
  'magit
  (advice-add 'magit-process-sentinel :before #'git-auto-sync--before-magit-sentinel-advice))

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
   (fboundp 'forge-pull)
   (core-message-info
    "Fetching forge git data for project: %s" (git-utils-format-repository-display repo-root))
   (forge-pull)))

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
     ;; Inject our wrapped callback that shows completion message and handles errors
     (condition-case err
         (funcall
          orig-fun repo
          (lambda
           ()
           (condition-case callback-err
               (progn
                (when original-callback (funcall original-callback))
                (core-message-success
                 "Fetched forge git data for project: %s"
                 (git-utils-format-repository-display repo-root)))
             (error
              (core-message-error
               "Failed to fetch forge git data for project: %s (error: %s)"
               (git-utils-format-repository-display repo-root)
               (error-message-string callback-err)))))
          since)
       (error
        (core-message-error
         "Failed to fetch forge git data for project: %s (error: %s)"
         (git-utils-format-repository-display repo-root)
         (error-message-string err))))
     ;; Pass through unchanged for non-auto-synced calls
     (funcall orig-fun repo callback since))))
 (with-eval-after-load
  'forge (advice-add 'forge--pull :around #'git-auto-sync--around-forge-pull-advice))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Core Sync Function (Manual and Auto both use this)
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  git-sync-repository ()
  "Manually sync both Magit and Forge data for the current repository.
This function can be called multiple times and will sync each time.
When called, it marks the repository as synced for this session."
  (interactive)
  (when-let ((repo-root (git-utils-find-repository-root)))
    (git-auto-sync--mark-repository-synced repo-root)
    (core-message-info
     "Initiated sync for repository: %s" (git-utils-format-repository-display repo-root))
    (git-auto-sync-magit-fetch repo-root)
    (git-auto-sync-forge-pull repo-root)))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Auto-Sync (Automatic on File Open)
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  git-auto-sync-repository-once ()
  "Auto-sync both Magit and Forge data once per repository when first file is opened.
Fetches Git refs via Magit and pulls Forge metadata via Forge API.
Runs only once per repository per Emacs session.
Skips remote files accessed via TRAMP."
  (when-let ((repo-root (git-utils-find-repository-root)))
    (if
     (file-remote-p repo-root)
     (core-message-debug
      "Skipping git auto-sync for remote repository (TRAMP): %s"
      (git-utils-format-repository-display repo-root))
     (unless (git-auto-sync--is-repository-synced-p repo-root) (git-sync-repository)))))
 (add-hook 'find-file-hook #'git-auto-sync-repository-once)
 (core-message-config
  "Git and Forge auto-sync configured (auto on file open, manual via git-sync-repository)"))
(provide 'git-sync)
;;; git-sync.el ends here
