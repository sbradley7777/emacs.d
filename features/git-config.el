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
;;      GitLab hosts authenticated via glab CLI are automatically added to forge-alist.
;;      You must complete two additional setup steps per repository:
;;
;;      1. Create and store GitLab token in ~/.authinfo:
;;         For gitlab.com:
;;           echo "machine gitlab.com/api/v4 login USERNAME^forge password GITLAB_TOKEN" >> ~/.authinfo
;;
;;         For self-hosted GitLab (example):
;;           echo "machine gitlab.example.com/api/v4 login USERNAME^forge password GITLAB_TOKEN" >> ~/.authinfo
;;
;;         Token creation:
;;           - GitLab.com: https://gitlab.com/-/profile/personal_access_tokens
;;           - Self-hosted: https://gitlab.example.com/-/profile/personal_access_tokens
;;           - Required scopes: api, read_api, read_user
;;
;;      2. Configure username per repository:
;;         The git config format is: gitlab.<APIHOST>.user
;;
;;         For gitlab.com repositories:
;;           cd /path/to/repo
;;           git config --local gitlab.gitlab.com/api/v4.user USERNAME
;;
;;         For self-hosted GitLab (example with gitlab.example.com):
;;           cd /path/to/repo
;;           git config --local gitlab.gitlab.example.com/api/v4.user USERNAME
;;
;;         IMPORTANT: The config variable name includes "/api/v4" which differs from
;;         the Forge documentation but is what Forge actually requires in practice.
;;
;;      Note: Replace USERNAME with your GitLab username and GITLAB_TOKEN with your token.
;;      The ^forge suffix in authinfo is required by the forge package.
(require 'core-utils)
(require 'git-utils)
(core-utils-with-load-timing
 "git-config.el"
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Magit Configuration
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (use-package
  magit
  :defer t
  :config
  (setq magit-display-buffer-function #'git-utils-magit-display-buffer-side)
  (advice-add 'magit-status-refresh-buffer :after #'git-utils-format-magit-buffer)
  (core-message-config "Magit configured for git integration"))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Forge Configuration
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (use-package
  forge
  :after magit
  :config
  (git-utils-setup-forge-gitlab-hosts)
  (core-message-config "Forge configured for GitHub/GitLab integration")))
(provide 'git-config)
;;; git-config.el ends here
