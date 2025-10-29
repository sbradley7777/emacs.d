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
  :config (core-message-config "Forge configured for GitHub/GitLab integration")))
(provide 'git-config)
;;; git-config.el ends here
