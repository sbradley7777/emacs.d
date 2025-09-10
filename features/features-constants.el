;;; features-constants.el --- Feature Configuration Constants -*- lexical-binding: t -*-

;;; Commentary:
;; This file contains constants used across various feature modules.
;; Constants are prefixed with 'features-' to avoid naming conflicts.


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; UI and Interaction Constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Completion (Corfu) Constants
(defconst features-corfu-auto-delay 0.2 "Corfu completion delay in seconds.")
(defconst features-corfu-auto-prefix 1 "Start completing after this many characters.")
(defconst features-corfu-min-width 20 "Minimum corfu popup width.")
(defconst features-corfu-max-width 100 "Maximum corfu popup width.")
(defconst features-corfu-count 10 "Maximum number of completion candidates shown.")

;; LSP Constants
(defconst features-eglot-send-changes-idle-time 0.5 "Eglot change notification frequency.")

;; Flymake Constants
(defconst features-flymake-window-width 100 "Flymake popup window width.")

;; Imenu-list Constants
(defconst features-imenu-list-size 0.25 "Imenu-list sidebar width as fraction of frame width.")

;; Indent Guides Constants
(defconst
 features-indent-guides-auto-char-face-perc 40 "Base visibility percentage for indent guides.")
(defconst
 features-indent-guides-auto-top-char-face-perc
 80
 "Top-level visibility percentage for indent guides.")
(defconst features-indent-guides-delay 0.1 "Delay before showing indent guides.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Color Constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

;;; Provide this module
(provide 'features-constants)

;;; features-constants.el ends here
