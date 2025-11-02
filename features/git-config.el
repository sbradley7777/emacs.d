;;; git-config.el --- Git Integration Configuration -*- lexical-binding: t -*-

;;; Commentary:
;;      Configuration for magit and forge integration.
;;      Provides git interface and GitHub/GitLab integration within Emacs.
;;
;;      For complete setup instructions, troubleshooting, and usage guide, see: GIT.md
;;
;;      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;      QUICK SETUP REFERENCE
;;      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;      STEP 1: Add forge host to ~/.gitconfig
;;        [emacs-forge "github.com"]
;;            apihost = api.github.com
;;            webhost = github.com
;;            type = github
;;            user = YOUR_USERNAME
;;
;;      STEP 2: Create personal access token
;;        GitHub: https://github.com/settings/tokens (scopes: repo, user, read:org)
;;        GitLab: https://gitlab.com/-/profile/personal_access_tokens (scopes: api, read_api, read_user)
;;
;;      STEP 3: Add credentials to ~/.authinfo
;;        echo "machine api.github.com login YOUR_USERNAME^forge password YOUR_TOKEN" >> ~/.authinfo
;;        chmod 600 ~/.authinfo
;;
;;      STEP 4: Restart Emacs or run
;;        M-x forge-gitconfig-populate-forge-alist-from-gitconfig
;;
;;      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;      AUTOMATIC FEATURES
;;      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;      - Forge hosts from ~/.gitconfig are automatically loaded on startup
;;      - Repository-local usernames are auto-configured when opening files in git repositories
;;      - Username is set in local .git/config (not global) for clean per-repository configuration
;;
;;      For detailed configuration examples, troubleshooting, and advanced usage, see: GIT.md
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
  (setq
   magit-display-buffer-function
   #'git-utils-magit-display-buffer-side
   magit-log-section-commit-count
   30
   magit-section-initial-visibility-alist
   '((stashes . show)
     (untracked . show)
     (unpushed . show)
     (unpulled . show)
     (unstaged . show)
     (staged . show)
     (issues . show)))
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
  (add-hook
   'forge-topic-mode-hook
   (lambda () (add-to-invisibility-spec 'markdown-markup) (visual-line-mode 1)))
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
