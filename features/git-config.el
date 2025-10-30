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
;;      FORGE CONFIGURATION - SETUP
;;      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;      All forge hosts (GitHub, GitLab, Gitea, etc.) are configured via ~/.gitconfig.
;;      This provides centralized configuration without dependency on CLI tools like gh or glab.
;;
;;      STEP 1: Add forge host configuration to ~/.gitconfig
;;      ------------------------------------------------------
;;      For GitHub (public):
;;        [emacs-forge "github.com"]
;;            apihost = api.github.com
;;            webhost = github.com
;;            type = github
;;            user = YOUR_USERNAME
;;
;;      For GitHub Enterprise:
;;        [emacs-forge "github.enterprise.com"]
;;            apihost = github.enterprise.com/api/v3
;;            webhost = github.enterprise.com
;;            type = github
;;            user = YOUR_USERNAME
;;
;;      For GitLab (public or self-hosted):
;;        [emacs-forge "gitlab.example.com"]
;;            apihost = gitlab.example.com/api/v4
;;            webhost = gitlab.example.com
;;            type = gitlab
;;            user = YOUR_USERNAME
;;
;;      For other forges (Gitea, Gogs, Bitbucket):
;;        Use the same pattern with appropriate apihost paths and type values.
;;        Supported types: github, gitlab, gitea, gogs, bitbucket
;;
;;      STEP 2: Create authentication tokens
;;      -------------------------------------
;;      GitHub:
;;        URL: https://github.com/settings/tokens (or your enterprise URL)
;;        Required scopes: repo, user, read:org
;;
;;      GitLab:
;;        URL: https://gitlab.example.com/-/profile/personal_access_tokens
;;        Required scopes: api, read_api, read_user
;;
;;      STEP 3: Add tokens to ~/.authinfo
;;      ----------------------------------
;;      Format: machine APIHOST login USERNAME^forge password TOKEN
;;
;;      For GitHub:
;;        echo "machine api.github.com login YOUR_USERNAME^forge password YOUR_GITHUB_TOKEN" >> ~/.authinfo
;;        chmod 600 ~/.authinfo
;;
;;      For GitLab:
;;        echo "machine gitlab.example.com/api/v4 login YOUR_USERNAME^forge password YOUR_GITLAB_TOKEN" >> ~/.authinfo
;;        chmod 600 ~/.authinfo
;;
;;      IMPORTANT:
;;        - The ^forge suffix is required by the forge package
;;        - APIHOST is the apihost value from your [emacs-forge] section in ~/.gitconfig
;;        - After adding hosts to ~/.gitconfig, restart Emacs or run:
;;          M-x forge-gitconfig-populate-forge-alist-from-gitconfig
;;
;;      Note: forge-alist and usernames are automatically configured on Emacs startup
;;      from the [emacs-forge] sections in ~/.gitconfig.
(require 'core-utils)
(require 'git-utils)
(require 'forge-gitconfig)
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
  (forge-gitconfig-populate-forge-alist-from-gitconfig)
  (add-hook 'forge-topic-mode-hook (lambda () (add-to-invisibility-spec 'markdown-markup)))
  (defun
   git-config--forge-fontify-with-hidden-markup
   (orig-fun text &optional indent)
   "Wrap forge--fontify-markdown to enable markdown-hide-markup."
   (let ((markdown-hide-markup t))
     (funcall orig-fun text indent)))
  (advice-add 'forge--fontify-markdown :around #'git-config--forge-fontify-with-hidden-markup)
  (core-message-config "Forge configured for GitHub/GitLab integration")))
(provide 'git-config)
;;; git-config.el ends here
