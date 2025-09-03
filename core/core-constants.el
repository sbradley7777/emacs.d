;;; core-constants.el --- Core Configuration Constants -*- lexical-binding: t -*-

;;; Commentary:
;; This file contains fundamental constants used across core configuration modules.
;; Constants are prefixed with 'core-' to avoid naming conflicts.


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Version and Compatibility Constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defconst
 core-minimum-emacs-version "26.0.50" "Minimum required Emacs version for this configuration.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Text and Editing Constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defconst core-fill-column 127 "Standard fill column for text wrapping and line length.")
(defconst core-tab-width 4 "Standard tab width for indentation.")
(defconst core-standard-indent 4 "Standard indentation size.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Performance and GC Constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Garbage Collection Thresholds
(defconst
 core-gc-startup-threshold most-positive-fixnum "GC threshold during startup (maximum possible).")
(defconst core-gc-normal-threshold (* 2 1000 1000) "Normal GC threshold (2MB).")
(defconst
 core-gc-long-session-threshold (* 100 1000 1000) "GC threshold for long sessions (100MB).")
(defconst core-gc-check-threshold 800000 "Threshold for checking if GC optimization is needed.")

;; Garbage Collection Percentages
(defconst core-gc-percentage-startup 0.6 "GC percentage during startup (60% of heap).")
(defconst core-gc-percentage-normal 0.1 "Normal GC percentage (10% of heap).")

;; Timing Constants
(defconst core-idle-update-delay-startup 1.0 "Idle update delay during startup.")
(defconst core-idle-update-delay-normal 0.5 "Normal idle update delay.")
(defconst core-gc-timer-interval 900 "GC optimization timer interval (15 minutes).")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; UI and Display Constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Scrolling and Navigation
(defconst core-scroll-step 1 "Scroll step for smooth scrolling.")
(defconst core-scroll-conservatively 10000 "Conservative scrolling threshold.")
(defconst core-show-paren-delay 0.1 "Parentheses highlighting delay.")

;; File and History Management
(defconst core-recentf-max-items 50 "Maximum recent files to remember.")
(defconst core-kept-old-versions 2 "Number of old file versions to keep.")
(defconst core-kept-new-versions 6 "Number of new file versions to keep.")

;; Auto-save Settings
(defconst core-auto-save-interval 200 "Auto-save every N keystrokes.")
(defconst core-auto-save-timeout 20 "Auto-save after N seconds of idle time.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Undo System Constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defconst core-undo-limit 6000000 "Normal undo entries kept in memory (6MB).")
(defconst core-undo-strong-limit 9000000 "Strongly-held undo entries (9MB).")
(defconst
 core-undo-outer-limit 12000000 "Maximum undo data before old entries are discarded (12MB).")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package Management Constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Archive Priorities
(defconst core-melpa-stable-priority 20 "Priority for MELPA stable packages.")
(defconst core-gnu-priority 15 "Priority for GNU packages.")
(defconst core-melpa-priority 10 "Priority for MELPA packages.")

;; Performance Reporting
(defconst
 core-use-package-minimum-reported-time 0.1 "Report packages taking longer than this to load.")

;; Which-key Configuration
(defconst core-which-key-idle-delay 0.3 "Which-key display delay.")
(defconst core-which-key-max-description-length 40 "Maximum which-key description length.")
(defconst core-which-key-column-padding 1 "Which-key column padding.")

;; Elisp Autofmt Configuration
(defconst core-elisp-autofmt-parallel-jobs 1 "Number of parallel jobs for elisp-autofmt.")

;;; Provide this module
(provide 'core-constants)

;;; core-constants.el ends here
