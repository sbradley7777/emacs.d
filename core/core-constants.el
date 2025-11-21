;;; core-constants.el --- Core Configuration Constants -*- lexical-binding: t -*-
;;; Commentary:
;; This file contains fundamental constants used across core configuration modules.
;; Constants are prefixed with 'core-' to avoid naming conflicts.

;;; Code:
(require 'core-utils)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load Path Auto-Detection Configuration
(defconst
 emacs-local-dir
 (expand-file-name "local/" user-emacs-directory)
 "Path to ~/.emacs.d/local/ directory.")
(defconst
 ignore-on-load '("configs" "local") "Directories to ignore when auto-detecting load paths.")
(defconst
 core-elisp-file-pattern "\\.el$" "Regular expression pattern matching Emacs Lisp source files.")

;; File Management (autosave, backup)
(core-utils-defconst-path
 core-files-autosave-dir "autosaves/" emacs-local-dir "Directory for autosave files.")
(core-utils-defconst-path
 core-files-auto-save-list-dir
 "auto-save-list/"
 emacs-local-dir
 "Directory for auto-save list files.")
(core-utils-defconst-path
 core-files-backup-dir "backups/" emacs-local-dir "Directory for backup files.")

;; Package System
(core-utils-defconst-path
 core-packages-dir "elpa" emacs-local-dir "Directory for installed packages.")
(core-utils-defconst-path
 core-eln-cache-dir "eln-cache" emacs-local-dir "Directory for native compilation cache.")
(core-utils-defconst-path
 core-package-metadata-file
 "package-metadata.el"
 emacs-local-dir
 "File storing package system persistent metadata and cache.")
(core-utils-defconst-path
 core-elisp-autofmt-cache-dir "elisp-autofmt-cache" emacs-local-dir
 "Directory for elisp-autofmt cache files.
Caching improves formatting performance by avoiding redundant analysis.")
(defconst
 core-byte-compile-dir-pattern "elc/%s"
 "Format pattern for version-specific byte-compiled files directory.
The %s placeholder is replaced with variable `emacs-version' to isolate compiled files by Emacs version.")

;; Project and Version Control
(core-utils-defconst-path
 core-projects-file "projects.el" emacs-local-dir "File storing known projects list.")
(core-utils-defconst-path
 core-forge-db-file "forge-database.sqlite" emacs-local-dir "SQLite database for forge data.")

;; Transient and Command History
(core-utils-defconst-path
 core-transient-history-file
 "transient/history.el"
 emacs-local-dir
 "File storing transient command history.")

;; Editor History and State
(core-utils-defconst-path
 core-savehist-file "history" emacs-local-dir "File storing minibuffer and command history.")
(core-utils-defconst-path
 core-recentf-file "recentf" emacs-local-dir "File storing recently opened files list.")

;; Logging
(core-utils-defconst-path core-log-dir "log" emacs-local-dir "Directory for log files.")
(defconst core-log-max-files 5 "Maximum number of rotated log files to keep.")
(defconst core-messages-log-file "messages.log" "Base name for messages log file.")

;; User Configuration Files
(core-utils-defconst-path
 core-custom-file
 "custom.el"
 user-emacs-directory
 "File for Emacs custom-set-variables and faces.")
(core-utils-defconst-path
 core-local-config-file
 "local.el"
 user-emacs-directory
 "File for user-specific local configuration.")
(core-utils-defconst-path
 core-dev-config-file
 "dev.el"
 user-emacs-directory
 "File for temporary development configuration.")

;; Early Startup Constants
(defconst core-gc-percentage-startup 0.6 "GC percentage during startup (60% of heap).")
(defconst core-idle-update-delay-startup 1.0 "Idle update delay during startup.")

;; Text and Editing Constants
(defconst core-fill-column 127 "Standard fill column for text wrapping and line length.")
(defconst core-tab-width 4 "Standard tab width for indentation.")
(defconst core-standard-indent 4 "Standard indentation size.")

;; Garbage Collection Thresholds
(defconst
 core-gc-startup-threshold most-positive-fixnum "GC threshold during startup (maximum possible).")
(defconst core-gc-normal-threshold (* 8 1000 1000) "Normal GC threshold for Emacs 30.2+ (8MB).")
(defconst
 core-gc-long-session-threshold
 (* 200 1000 1000)
 "Long session GC threshold for Emacs 30.2+ (200MB).")
(defconst core-gc-check-threshold 800000 "Threshold for checking if GC optimization is needed.")

;; Garbage Collection Percentages
(defconst core-gc-percentage-normal 0.1 "Normal GC percentage (10% of heap).")

;; Timing Constants
(defconst core-idle-update-delay-normal 0.5 "Normal idle update delay.")
(defconst
 core-ui-instant-feedback-delay 0.1
 "Instant UI feedback delay (100ms).
Standard delay for visual feedback that should appear immediately when triggered,
such as parentheses highlighting, indent guides, and completion documentation popups.")

;; Time Display
(defconst
 core-time-format
 "%Y-%m-%d %H:%M"
 "Standard time display format for modeline and diagnostics (YYYY-MM-DD HH:MM).")

;; Scrolling and Navigation
(defconst core-scroll-step 1 "Scroll step for smooth scrolling.")
(defconst core-scroll-conservatively 10000 "Conservative scrolling threshold.")
(defconst core-show-paren-delay core-ui-instant-feedback-delay "Parentheses highlighting delay.")

;; File and History Management
(defconst core-recentf-max-items 50 "Maximum recent files to remember.")
(defconst core-kept-old-versions 2 "Number of old file versions to keep.")
(defconst core-kept-new-versions 6 "Number of new file versions to keep.")

;; Auto-save Settings
(defconst core-auto-save-interval 200 "Auto-save every N keystrokes.")
(defconst core-auto-save-timeout 20 "Auto-save after N seconds of idle time.")

;; Undo System Constants
(defconst core-undo-limit 6000000 "Normal undo entries kept in memory (6MB).")
(defconst core-undo-strong-limit 9000000 "Strongly-held undo entries (9MB).")
(defconst
 core-undo-outer-limit 12000000 "Maximum undo data before old entries are discarded (12MB).")

;; Archive Priorities
(defconst core-melpa-stable-priority 20 "Priority for MELPA stable packages.")
(defconst core-gnu-priority 15 "Priority for GNU packages.")
(defconst core-melpa-priority 10 "Priority for MELPA packages.")

;; Network Timeouts
(defconst
 core-package-refresh-timeout
 60
 "Timeout in seconds for package repository refresh operations (downloads metadata from GNU, NonGNU, MELPA).")

;; Performance Reporting
(defconst
 core-use-package-minimum-reported-time 0.1 "Report packages taking longer than this to load.")

;; Elisp Autofmt Configuration
(defconst core-elisp-autofmt-parallel-jobs 1 "Number of parallel jobs for elisp-autofmt.")

;; Package List Display
(defconst
 core-package-list-column-widths '(40 20 18 22)
 "Column widths for package list display table.
List of integers representing character widths for: package-name, installed-version, update-available, status.")
(provide 'core-constants)
;;; core-constants.el ends here
