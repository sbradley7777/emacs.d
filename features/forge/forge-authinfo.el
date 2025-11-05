;;; forge-authinfo.el --- Interactive authinfo generator for forge hosts -*- lexical-binding: t -*-

;;; Commentary:
;; Interactive helper to generate ~/.authinfo entries for forge hosts
;; configured in ~/.gitconfig but missing authentication credentials.
;;
;; IMPORTANT: Automatically appends ^forge suffix to usernames
;; The ^forge suffix is required by the ghub/forge package to identify
;; tokens used for Forge operations vs. other API access.
;;
;; Format: machine APIHOST login USERNAME^forge password TOKEN
(require 'core-logging)
(require 'core-utils)
(require 'forge-constants)
(require 'forge-gitconfig)
(require 'forge-utils)
(core-utils-with-load-timing
 "forge-authinfo.el"
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Helper Functions
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  forge-authinfo--parse-existing-entries ()
  "Parse existing ~/.authinfo and return list of machine hosts.
Returns empty list if file doesn't exist."
  (let ((entries (forge-utils-parse-authinfo))
        (machines '()))
    (dolist
     (entry entries)
     (let ((machine (plist-get entry :machine)))
       (when machine (push machine machines))))
    machines))

 (defun
  forge-authinfo--format-entry (machine login token)
  "Format a single authinfo line from MACHINE, LOGIN, and TOKEN.
Returns formatted string suitable for ~/.authinfo.
Automatically appends ^forge suffix to login for Forge authentication."
  (format "machine %s login %s%s password %s" machine login forge-authinfo-username-suffix token))

 (defun
  forge-authinfo--ensure-file-permissions (file)
  "Ensure FILE has secure 600 permissions.
Returns t on success, nil on failure."
  (condition-case err
      (progn (set-file-modes file #o600) t)
    (error
     (core-message-error
      "Failed to set permissions on %s: %s" (abbreviate-file-name file) (error-message-string err))
     nil)))

 (defun
  forge-authinfo--validate-inputs (username token)
  "Validate that USERNAME and TOKEN are non-empty strings.
Returns t if valid, nil otherwise."
  (and
   (stringp username)
   (not (string-empty-p username))
   (stringp token)
   (not (string-empty-p token))))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Main Interactive Function
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  forge-authinfo-generate-entries ()
  "Generate ~/.authinfo entries for forge hosts missing authentication.
Reads [emacs-forge] sections from ~/.gitconfig and checks which hosts
are missing credentials in ~/.authinfo. For each missing host, prompts
the user for authentication token and generates the authinfo entry.
Only prompts for hosts that are properly configured in ~/.gitconfig."
  (interactive)
  (let* ((hosts (forge-gitconfig-parse-hosts-from-gitconfig))
         (existing-machines (forge-authinfo--parse-existing-entries))
         (authinfo-file (expand-file-name forge-authinfo-path))
         (new-entries '())
         (processed-count 0)
         (skipped-count 0))
    (if
     (null hosts) (core-message-warning "No [emacs-forge] sections found in ~/.gitconfig")
     (progn
      (core-message-info
       "Checking %d forge host%s..." (length hosts) (if (= (length hosts) 1) "" "s"))
      (dolist
       (host hosts)
       (let* ((config (forge-gitconfig-parse-config-for-host host))
              (api-host (plist-get config :apihost))
              (user (plist-get config :user))
              (forge-type (plist-get config :type)))
         (cond
          ((not config)
           (core-message-warning "Failed to parse config for host '%s', skipping" host)
           (setq skipped-count (1+ skipped-count)))
          ((not api-host)
           (core-message-warning "Host '%s' missing apihost in ~/.gitconfig, skipping" host)
           (setq skipped-count (1+ skipped-count)))
          ((member api-host existing-machines)
           (core-message-info "Host '%s' already has credentials in ~/.authinfo" api-host)
           (setq skipped-count (1+ skipped-count)))
          (t
           (let* ((username (if user user (read-string (format "Username for %s: " api-host))))
                  (token (read-passwd (format "Token for %s: " api-host))))
             (if
              (forge-authinfo--validate-inputs username token)
              (progn
               (push (forge-authinfo--format-entry api-host username token) new-entries)
               (setq processed-count (1+ processed-count))
               (core-message-success "Prepared entry for %s" api-host))
              (core-message-warning "Skipping %s (empty username or token)" api-host)
              (setq skipped-count (1+ skipped-count))))))))
      (if
       (null new-entries) (core-message-info "No new entries to add to ~/.authinfo")
       (condition-case err
           (progn
            (let ((file-existed (file-exists-p authinfo-file)))
              (with-temp-buffer
               (when file-existed (insert-file-contents authinfo-file))
               (goto-char (point-max))
               (unless (or (bobp) (eq (char-before) ?\n)) (insert "\n"))
               (dolist (entry (reverse new-entries)) (insert entry "\n"))
               (write-region (point-min) (point-max) authinfo-file nil 'quiet))
              (when
               (forge-authinfo--ensure-file-permissions authinfo-file)
               (core-message-success
                "Added %d entr%s to ~/.authinfo"
                processed-count
                (if (= processed-count 1) "y" "ies"))
               (when
                (> skipped-count 0)
                (core-message-info
                 "Skipped %d host%s" skipped-count (if (= skipped-count 1) "" "s"))))))
         (error
          (core-message-error "Failed to write ~/.authinfo: %s" (error-message-string err)))))))))

 (core-message-config "Forge authinfo generator loaded"))
(provide 'forge-authinfo)
;;; forge-authinfo.el ends here
