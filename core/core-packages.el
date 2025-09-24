;;; core-packages.el --- Package Declarations and Configurations -*- lexical-binding: t -*-
;;; Commentary:
;;      Package installation and configuration using use-package.

(require 'core-constants)
(require 'core-utils)
(require 'package-system/repositories)

(core-utils-with-load-timing
 "core-packages.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Essential Package Categories
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Organized package lists for better maintainability
 (defvar
  core-packages-essential
  '(doom-themes yaml-mode toml-mode markdown-mode)
  "Essential packages that must be installed.")

 (defvar
  core-packages-development
  '(which-key
    pyvenv
    elisp-autofmt
    corfu
    rainbow-delimiters
    highlight-indent-guides
    imenu-list
    cape
    flymake-ruff
    treemacs
    all-the-icons
    treemacs-all-the-icons
    treemacs-icons-dired
    treemacs-nerd-icons)
  "Development and programming packages.")

 (defvar
  core-packages-all
  (append core-packages-essential core-packages-development)
  "Complete list of packages to install.")

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Robust Package Installation
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  core-packages-install-safely
  (package-list)
  "Install packages from PACKAGE-LIST with comprehensive error handling."
  (let ((failed-packages '())
        (installed-count 0)
        (skipped-count 0))

    (message "📦  Installing %d packages..." (length package-list))

    (dolist
     (package package-list)
     (cond
      ;; Already installed
      ((package-installed-p package)
       (setq skipped-count (1+ skipped-count))
       (message "✅  Already installed: %s" package))

      ;; Install with error handling
      (t
       (condition-case err
           (progn
            (package-install package)
            (setq installed-count (1+ installed-count))
            (message "✅  Installed: %s" package))
         (error
          (push package failed-packages)
          (message "❌  Failed to install %s: %s" package (error-message-string err)))))))

    ;; Installation summary
    (message "\n=== Package Installation Summary ===")
    (message "    ℹ️  Installed: %d packages" installed-count)
    (message "    ℹ️  Already present: %d packages" skipped-count)
    (when
     failed-packages
     (message "    ❌  Failed: %d packages" (length failed-packages))
     (dolist (pkg failed-packages) (message "  ❌  %s" pkg))
     (message "    ℹ️  Consider running (package-refresh-contents) and retrying failed packages"))
    (message "===================================\n")

    ;; Return list of failed packages for further handling
    failed-packages))

 ;; Add retry mechanism for automatic recovery from network failures
 (defun
  core-packages-install-with-retry (package-list &optional max-retries)
  "Install packages with automatic retry on network failures.
PACKAGE-LIST is the list of packages to install.
MAX-RETRIES is the maximum number of retry attempts (default: 2)."
  (let ((max-retries (or max-retries 2))
        (failed-packages (core-packages-install-safely package-list)))
    (when
     (and failed-packages (> max-retries 0))
     (message "🔄 Retrying failed packages after network refresh...")
     (package-refresh-contents)
     (core-packages-install-with-retry failed-packages (1- max-retries)))))

 ;; Install packages using robust installation function with retry
 (core-packages-install-with-retry core-packages-all)

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Package configurations using use-package
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (use-package doom-themes :defer t) ; Deferred loading for doom themes collection
 (use-package yaml-mode :mode ("\\.ya?ml\\'" . yaml-mode)) ; YAML file support
 (use-package toml-mode :mode ("\\.toml\\'" . toml-mode)) ; TOML file support
 (use-package markdown-mode :mode ("\\.md\\'" . markdown-mode)) ; Markdown file support
 (use-package flymake-ruff :defer t) ; Deferred loading for ruff integration


 (use-package
  which-key
  :config (which-key-mode 1)
  (setq
   which-key-idle-delay core-which-key-idle-delay ; Faster response
   which-key-max-description-length core-which-key-max-description-length ; Longer descriptions
   which-key-add-column-padding core-which-key-column-padding ; Better spacing
   which-key-separator " → "))

 (use-package
  elisp-autofmt
  :config
  ;; Configure elisp-autofmt for consistent formatting
  (setq elisp-autofmt-style 'native) ; Use native Emacs indentation style
  (setq elisp-autofmt-parallel-jobs core-elisp-autofmt-parallel-jobs)) ; Single-threaded for consistency

 ;; Make this module available for loading with (require 'core-packages)
 (provide 'core-packages))
