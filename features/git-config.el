;;; git-config.el --- Git Integration Configuration -*- lexical-binding: t -*-

;;; Commentary:
;;      Configuration for magit and forge integration.
;;      Provides git interface and GitHub/GitLab integration within Emacs.
;;
;;      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;      GIT USER CONFIGURATION
;;      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;      Configure git user settings globally or per-repository:
;;
;;        Global configuration (applies to all repositories):
;;          git config --global user.name "Your Name"
;;          git config --global user.email "your.email@example.com"
;;
;;        Local configuration (repository-specific, overrides global):
;;          cd /path/to/repository
;;          git config user.name "Your Name"
;;          git config user.email "your.email@example.com"
;;
;;      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;      FORGE AUTHENTICATION - GITHUB
;;      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;      Reuse existing gh CLI token:
;;        If you have gh CLI authenticated, reuse its token:
;;          echo "machine api.github.com login USERNAME^forge password $(gh auth token)" > ~/.authinfo
;;          chmod 600 ~/.authinfo
;;
;;      Create GitHub token manually (if not using gh CLI):
;;        Create token at https://github.com/settings/tokens
;;          Required scopes: repo, user, read:org
;;
;;        Add to ~/.authinfo:
;;          echo "machine api.github.com login USERNAME^forge password GITHUB_TOKEN" > ~/.authinfo
;;          chmod 600 ~/.authinfo
;;
;;      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;      FORGE AUTHENTICATION - GITLAB
;;      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;      Create GitLab token:
;;        Create token at https://gitlab.com/-/profile/personal_access_tokens
;;          Required scopes: api, read_api, read_user
;;
;;        Add to ~/.authinfo:
;;          echo "machine gitlab.com login USERNAME^forge password GITLAB_TOKEN" >> ~/.authinfo
;;
;;      For self-hosted GitLab:
;;          echo "machine gitlab.example.com login USERNAME^forge password GITLAB_TOKEN" >> ~/.authinfo
;;
;;      Note: Replace USERNAME with your GitHub/GitLab username.
;;      The ^forge suffix is required by the forge package.
(require 'core-utils)
(core-utils-with-load-timing
 "git-config.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Magit Configuration
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  git-config-magit-display-buffer-side
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
  git-config-format-magit-buffer
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

 (use-package
  magit
  :defer t
  :config
  (setq magit-display-buffer-function #'git-config-magit-display-buffer-side)
  (advice-add 'magit-status-refresh-buffer :after #'git-config-format-magit-buffer)
  (core-message-config "Magit configured for git integration"))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Forge Configuration
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  user-git-issues (&optional repo)
  "List forge issues directly without showing the transient menu.
Optional REPO argument specifies which repository to list issues for."
  (interactive) (require 'forge-topics) (forge-topics-setup-buffer repo nil :type 'issue))

 (use-package
  forge
  :after magit
  :config (core-message-config "Forge configured for GitHub/GitLab integration")))
(provide 'git-config)
;;; git-config.el ends here
