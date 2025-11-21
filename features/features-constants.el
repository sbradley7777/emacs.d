;;; features-constants.el --- Feature Configuration Constants -*- lexical-binding: t -*-
;;; Commentary:
;; This file contains constants used across various feature modules.
;; Constants are prefixed with 'features-' to avoid naming conflicts.

;;; Code:
(require 'core-constants)
(require 'core-utils)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; File Location Constants
(core-utils-defconst-path
 features-treesit-grammars-dir
 "tree-sitter/"
 emacs-local-dir
 "Directory for tree-sitter grammar libraries.")
(core-utils-defconst-path
 features-tramp-cache-file
 "tramp"
 emacs-local-dir
 "File for TRAMP connection cache and persistence data.")
(core-utils-defconst-path
 features-tramp-autosave-dir
 "tramp-autosave"
 emacs-local-dir
 "Directory for TRAMP remote file autosaves.")
(core-utils-defconst-path
 features-treemacs-persist-file
 "treemacs-persist"
 emacs-local-dir
 "File for treemacs workspace and project state persistence.")

;; Completion (Corfu) Constants
(defconst features-corfu-auto-delay 0.2 "Corfu completion delay in seconds.")
(defconst features-corfu-auto-prefix 1 "Start completing after this many characters.")
(defconst features-corfu-min-width 20 "Minimum corfu popup width.")
(defconst features-corfu-max-width 100 "Maximum corfu popup width.")
(defconst features-corfu-count 10 "Maximum number of completion candidates shown.")

;; Window Constants
(defconst
 features-side-window-compact-width 0.3
 "Width for compact side windows (30% of frame).
Used by flymake diagnostics, forge issues, magit, and other side windows.")
(defconst
 features-side-window-expanded-width 0.5
 "Width for expanded toggleable side windows (50% of frame).
Used by toggle commands for flymake diagnostics, forge issues, and other side windows.")

;; Indent Guides Constants
(defconst
 features-indent-guides-auto-char-face-perc 40 "Base visibility percentage for indent guides.")
(defconst
 features-indent-guides-auto-top-char-face-perc
 80
 "Top-level visibility percentage for indent guides.")
(defconst
 features-indent-guides-delay core-ui-instant-feedback-delay "Delay before showing indent guides.")

;; Which-key Constants
(defconst features-which-key-idle-delay 0.3 "Which-key display delay.")
(defconst features-which-key-max-description-length 40 "Maximum which-key description length.")
(defconst features-which-key-column-padding 1 "Which-key column padding.")
(defconst features-which-key-separator " → " "Separator displayed between key and description.")

;; Rainbow Delimiters Color Palette
(defconst features-color-delimiter-1 "#ff6b6b" "Bright red for delimiter depth 1.")
(defconst features-color-delimiter-2 "#ffa500" "Bright orange for delimiter depth 2.")
(defconst features-color-delimiter-3 "#ffeb3b" "Bright yellow for delimiter depth 3.")
(defconst features-color-delimiter-4 "#4caf50" "Bright green for delimiter depth 4.")
(defconst features-color-delimiter-5 "#00bcd4" "Bright cyan for delimiter depth 5.")
(defconst features-color-delimiter-6 "#2196f3" "Bright blue for delimiter depth 6.")
(defconst features-color-delimiter-7 "#9c27b0" "Bright purple for delimiter depth 7.")
(defconst features-color-delimiter-8 "#e91e63" "Bright magenta for delimiter depth 8.")
(defconst features-color-delimiter-9 "#ff4081" "Bright pink for delimiter depth 9.")
(defconst features-color-delimiter-unmatched "#f44336" "Error red for unmatched delimiters.")
(defconst features-color-delimiter-error-bg "#f44336" "Background color for delimiter errors.")
(defconst features-color-delimiter-error-fg "#ffffff" "Foreground color for delimiter errors.")

;; Indent Guide Colors
(defconst features-color-indent-guide-odd "#2a2a2a" "Odd level indent guide background.")
(defconst features-color-indent-guide-even "#3a3a3a" "Even level indent guide background.")
(defconst features-color-indent-guide-char "#4a4a4a" "Indent guide character color.")
(defconst features-color-indent-guide-top-odd "#404040" "Top-level odd indent guide background.")
(defconst features-color-indent-guide-top-even "#505050" "Top-level even indent guide background.")
(defconst features-color-indent-guide-top-char "#707070" "Top-level indent guide character color.")
(provide 'features-constants)
;;; features-constants.el ends here
