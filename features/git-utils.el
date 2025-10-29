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
 ;; Forge Utility Functions
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; These functions automatically detect GitLab hosts authenticated via the glab CLI
 ;; and add them to forge-alist so that Forge can work with custom GitLab instances.
 ;;
 ;; IMPORTANT: Username Configuration
 ;; After forge-alist is configured, you must also set your username per repository:
 ;;
 ;; For custom GitLab instances, use this format:
 ;;   git config --local gitlab.<APIHOST>.user <USERNAME>
 ;;
 ;; Example for gitlab.example.com:
 ;;   git config --local gitlab.gitlab.example.com/api/v4.user USERNAME
 ;;
 ;; Note: The format includes "/api/v4" in the config variable name, which differs
 ;; from the Forge documentation but is what Forge actually looks for in practice.
 ;;
 ;; See git-config.el commentary for authentication token setup instructions.

 (defun
  git-utils-parse-glab-hosts ()
  "Parse output of 'glab auth status' and return list of authenticated GitLab hosts.
Returns a list of plists with :host and :username keys.

Example output format:
  ((:host \"gitlab.com\" :username \"user1\")
   (:host \"gitlab.example.com\" :username \"user2\"))

The function parses glab CLI output which has this structure:
  hostname
    ✓ Logged in to hostname as username (...)

Returns nil if glab is not installed or not authenticated."
  (condition-case err
      (if
       (not (core-utils-check-command-in-path "glab"))
       (progn (core-message-debug "glab CLI not found, skipping GitLab host detection") nil)
       (let ((output (shell-command-to-string "glab auth status 2>&1"))
             (hosts nil)
             (current-host nil))
         (with-temp-buffer
          (insert output) (goto-char (point-min))
          (while
           (not (eobp))
           (cond
            ;; Match standalone hostname line
            ((looking-at "^\\([a-zA-Z0-9.-]+\\)$")
             (let ((host (match-string 1)))
               (when
                (and
                 (not (string-prefix-p "uptime:" host))
                 (not (member host '("USAGE" "FLAGS" "EXAMPLES"))))
                (setq current-host host))))
            ;; Match "Logged in to ... as USERNAME" line
            ((and current-host (looking-at "^  ✓ Logged in to .+ as \\([^ ]+\\) "))
             (let ((username (match-string 1)))
               (push (list :host current-host :username username) hosts)
               (setq current-host nil))))
           (forward-line 1)))
         (reverse hosts)))
    (error
     (core-message-warning "Failed to parse glab hosts: %s" (error-message-string err))
     nil)))

 (defun
  git-utils-create-forge-gitlab-entry (host)
  "Create a forge-alist entry for GitLab HOST.
Returns a list in the format (GITHOST APIHOST WEBHOST CLASS).

The forge-alist format is:
  (GITHOST APIHOST WEBHOST CLASS)

Where:
  GITHOST - Host used for Git operations (e.g., \"gitlab.example.com\")
  APIHOST - API endpoint including path (e.g., \"gitlab.example.com/api/v4\")
  WEBHOST - Host for web browser access (e.g., \"gitlab.example.com\")
  CLASS   - Forge class symbol (forge-gitlab-repository)

Example:
  (git-utils-create-forge-gitlab-entry \"gitlab.example.com\")
  => (\"gitlab.example.com\" \"gitlab.example.com/api/v4\" \"gitlab.example.com\" forge-gitlab-repository)"
  (list host (concat host "/api/v4") host 'forge-gitlab-repository))

 (defun
  git-utils-setup-forge-gitlab-hosts ()
  "Setup forge-alist with authenticated GitLab hosts from glab CLI.

This function:
1. Executes 'glab auth status' to find authenticated GitLab instances
2. Parses the output to extract host information
3. Adds missing hosts to forge-alist so Forge can access them

The function only configures forge-alist. You must separately configure
usernames per repository using git config. See the section comments above
for username configuration instructions.

This function is called automatically when Forge loads (see git-config.el).
You can also call it interactively to refresh the list of GitLab hosts."
  (interactive)
  (condition-case err
      (progn
       (require 'forge nil t)
       (let ((host-info-list (git-utils-parse-glab-hosts))
             (added-count 0))
         (if
          (null host-info-list) (core-message-info "No authenticated GitLab hosts found via glab")
          (dolist
           (host-info host-info-list)
           (let ((host (plist-get host-info :host)))
             ;; Only add if not already present to avoid duplicates
             (unless
              (assoc host forge-alist)
              (push (git-utils-create-forge-gitlab-entry host) forge-alist)
              (setq added-count (1+ added-count))
              (core-message-config "Added GitLab host to forge-alist: %s" host))))
          (if
           (> added-count 0)
           (core-message-success
            "Added %d GitLab host%s to forge-alist" added-count (if (= added-count 1) "" "s"))
           (core-message-info "All GitLab hosts already configured in forge-alist")))))
    (error
     (core-message-error "Failed to setup forge GitLab hosts: %s" (error-message-string err)))))

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
 (core-message-config "Git utility functions loaded"))
(provide 'git-utils)
;;; git-utils.el ends here
