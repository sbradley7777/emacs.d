;;; core-packages.el --- Package Declarations and Configurations -*- lexical-binding: t -*-
;;; Commentary:
;;      Package installation and configuration using use-package.

(require 'package-system/metadata)
(require 'package-system/repositories)
(require 'core-packages-utils)

(core-utils-with-load-timing
 "core-packages.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Package Categories
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Packages organized by function and load order for better maintainability.
 ;; Categories: interface -> editing -> development -> languages

 (defvar
  core-packages-interface
  '(doom-themes
    doom-modeline
    which-key
    rainbow-delimiters
    highlight-indent-guides
    kind-icon
    nerd-icons-dired
    treemacs-nerd-icons
    dashboard)
  "UI/UX essentials for all users.
Themes, visual enhancements, icons, and interface helpers.")

 (defvar
  core-packages-editing '(corfu cape imenu-list imenu-anywhere treemacs breadcrumb dired-subtree)
  "Text manipulation and navigation tools for all users.
Completion, navigation, and file browsing functionality.")

 (defvar
  core-packages-development '(flymake-ruff elisp-autofmt treesit-auto diff-hl)
  "Programming-specific development tools.
Linting, formatting, code analysis, tree-sitter support, and git diff visualization.")

 (defvar
  core-packages-languages '(pyvenv yaml-mode toml-mode markdown-mode)
  "Language-specific modes and tools.
File type handlers and language-specific utilities.")

 (defvar
  core-packages-all
  (append
   core-packages-interface core-packages-editing core-packages-development core-packages-languages)
  "Complete list of all packages to install.
Assembled from all category lists in load order.")

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Package Installation
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Install packages using robust installation function with retry from core-packages-utils
 (core-packages-install-with-retry core-packages-all)

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Package configurations using use-package
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (use-package doom-themes :defer t) ; Deferred loading for doom themes collection
 (use-package yaml-mode :mode ("\\.ya?ml\\'" . yaml-mode)) ; YAML file support
 (use-package toml-mode :mode ("\\.toml\\'" . toml-mode)) ; TOML file support
 (use-package markdown-mode :mode ("\\.md\\'" . markdown-mode)) ; Markdown file support
 (use-package flymake-ruff :defer t) ; Deferred loading for ruff integration
 (use-package imenu-anywhere :defer t) ; Cross-buffer symbol search (keybinding in keybindings.el)

 ;; NOTE: json-mode is intentionally NOT installed
 ;; - It conflicts with treesit-auto by adding itself to auto-mode-alist
 ;; - treesit-auto handles JSON: js-json-mode → prompt → json-ts-mode
 ;; - js-json-mode (built-in) is sufficient as fallback without tree-sitter grammar

 (use-package
  which-key
  :config (which-key-mode 1)
  (setq
   which-key-idle-delay core-which-key-idle-delay ; Faster response
   which-key-max-description-length core-which-key-max-description-length ; Longer descriptions
   which-key-add-column-padding core-which-key-column-padding ; Better spacing
   which-key-separator core-which-key-separator))

 (use-package
  elisp-autofmt
  :config
  ;; Configure elisp-autofmt for consistent formatting
  (setq elisp-autofmt-style 'native) ; Use native Emacs indentation style
  (setq elisp-autofmt-parallel-jobs core-elisp-autofmt-parallel-jobs) ; Single-threaded for consistency
  (setq elisp-autofmt-cache-directory core-elisp-autofmt-cache-dir)) ; Use local directory

 (use-package
  treesit-auto
  :custom (treesit-auto-install 'prompt) ; Prompt before installing grammars
  :config (global-treesit-auto-mode)) ; Enable automatic tree-sitter mode selection

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Automatic Weekly Update Check
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Run automatic weekly update check from core-packages-utils
 (core-packages-check-weekly-updates)

 ;; Make this module available for loading with (require 'core-packages)
 )

(provide 'core-packages)
