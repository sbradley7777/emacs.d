;;; core-packages.el --- Package Declarations and Configurations -*- lexical-binding: t -*-
;;; Commentary:
;;      Package installation and configuration using use-package.

(require 'core-constants)
(require 'core-utils)
(require 'package-system/metadata)
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
       (core-utils-increment-counter skipped-count)
       (message "✅  Already installed: %s" package))

      ;; Install with error handling
      (t
       (condition-case err
           (progn
            (package-install package)
            (core-utils-increment-counter installed-count)
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
  (setq elisp-autofmt-parallel-jobs core-elisp-autofmt-parallel-jobs) ; Single-threaded for consistency
  (setq elisp-autofmt-cache-directory (expand-file-name "elisp-autofmt-cache" emacs-local-dir))) ; Use local directory

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Package Update Functions
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (defun
  core-packages-safe-refresh-and-check (timeout-seconds)
  "Safely refresh package contents and return available upgrades.
Returns a list of available upgrades or nil if failed/no upgrades.
TIMEOUT-SECONDS specifies how long to wait before timing out."
  (when
   (and
    (require 'package-system/network nil t) (fboundp 'network-responsive-p) (network-responsive-p))
   (condition-case err
       (progn
        (with-timeout
         (timeout-seconds (message "⚠️  Package update check timed out"))
         (package-refresh-contents))
        (package-menu--find-upgrades))
     (error
      (message "⚠️  Package update check failed: %s" (error-message-string err))
      nil))))

 (defun
  show-package-upgrades
  ()
  "Show only installed packages that have available upgrades.
Refreshes package contents and displays a list of packages with available updates,
showing current version -> new version for each package."
  (interactive)
  (message "📦  Checking for package updates (manual check)...")
  (message "🔍  Configured repositories: %s" (mapcar 'car package-archives))
  (let ((upgrades (core-packages-safe-refresh-and-check core-package-refresh-timeout)))
    (if
     upgrades
     (progn
      (message
       "✅  Package refresh completed successfully - contacted %d repositories"
       (length package-archives))
      (message "📦  Found %d packages with updates available:" (length upgrades))
      (dolist
       (pkg upgrades)
       (let ((pkg-name (car pkg))
             (current-desc (cadr pkg))
             (new-desc (caddr pkg)))
         (message
          "  📦  %s: %s → %s"
          pkg-name
          (package-desc-version current-desc)
          (package-desc-version new-desc))))
      (message "📦  Run M-x package-list-packages, then 'U' and 'x' to install updates"))
     (progn
      (message
       "✅  Package refresh completed successfully - contacted %d repositories"
       (length package-archives))
      (message "📦  No package updates available - all packages are up to date.")))))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Automatic Weekly Update Check with Persistent Storage
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


 ;; Automatically check for package updates once per week during interactive Emacs sessions.
 ;; This provides awareness of available updates without automatically installing them.
 ;;
 ;; How it works:
 ;; - Runs only during interactive sessions (not batch mode)
 ;; - Checks if 7 days have passed since last package list refresh (persistent across sessions)
 ;; - Refreshes package contents from repositories (MELPA, GNU ELPA, etc.)
 ;; - Notifies user if updates are available but does NOT install them
 ;; - User can run M-x show-package-upgrades for details or M-x package-list-packages to install
 ;;
 ;; Benefits:
 ;; - Stay informed about available updates (like the doom-themes fix we just applied)
 ;; - Maintains stability by requiring manual approval before installing updates
 ;; - Prevents surprise breakage from automatic updates
 ;; - Weekly frequency avoids slowing down daily startup times
 ;; - Persistent storage prevents duplicate checks across Emacs restarts
 (let ((last-check-timestamp (package-metadata-read-refresh-timestamp))
       (days-since-last-check
        (/
         (float-time
          (time-subtract
           (current-time) (seconds-to-time (package-metadata-read-refresh-timestamp))))
         (* 24 60 60))))
   (if
    (and
     ;; Check if more than 7 days have passed since last refresh
     (>
      (float-time (time-subtract (current-time) (seconds-to-time last-check-timestamp)))
      (* 7 24 60 60)) ; 7 days in seconds
     ;; Only during interactive sessions, not batch mode
     (not noninteractive)
     ;; Only if network is available
     (require 'package-system/network nil t)
     (fboundp 'network-responsive-p)
     (network-responsive-p))
    ;; Perform weekly check
    (progn
     (message "📦  Checking for package updates (weekly check)...")
     (message "🔍  Configured repositories: %s" (mapcar 'car package-archives))
     ;; Refresh package contents with timeout protection
     (condition-case err
         (progn
          (let ((refresh-successful nil))
            (with-timeout
             (core-package-refresh-timeout
              (message "⚠️  Package update check timed out - skipping")
              (setq refresh-successful nil))
             (package-refresh-contents) (setq refresh-successful t))
            (if
             refresh-successful
             (progn
              (message
               "✅  Package refresh completed successfully - contacted %d repositories"
               (length package-archives))
              ;; Check what packages have available updates
              (let ((upgrades (package-menu--find-upgrades)))
                (if
                 upgrades
                 (message
                  "📦  Found %d package updates available. Run M-x show-package-upgrades for details."
                  (length upgrades))
                 (message "📦  No package updates available - all packages are up to date.")))
              ;; Only update timestamp after EVERYTHING completed successfully
              (package-metadata-write-refresh-timestamp (float-time (current-time))))
             (message "⚠️  Package refresh incomplete - will retry next startup"))))
       (error
        (message "❌  Package refresh failed: %s" (error-message-string err))
        ;; Still mark as checked to prevent repeated attempts
        (package-metadata-write-refresh-timestamp (float-time (current-time))))))
    ;; Skip check and inform user
    (when
     (not noninteractive)
     (message
      "📦  Skipping package check (%.1f days since last check, checking weekly)"
      days-since-last-check))))

 ;; Make this module available for loading with (require 'core-packages)
 (provide 'core-packages))
