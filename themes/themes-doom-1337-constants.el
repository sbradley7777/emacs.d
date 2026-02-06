;;; themes-doom-1337-constants.el --- Doom 1337 Theme Color Constants -*- lexical-binding: t -*-
;;; Commentary:
;; WHAT: Color constants for doom-1337 theme
;; WHY:  Centralizes color definitions for reuse across theme customizations
;; PROVIDES: Color palette constants for doom-1337 theme
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; All color constants used by doom-1337 theme customizations including:
;; - Comment and doc colors
;; - Modeline color palette
;; - Accent colors for UI elements
;; - Search and highlight colors

;;; Code:
(require 'core-utils)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defconst
 themes-doom-1337-comment-color
 "#989898"
 "Custom comment color for doom-1337 theme - light gray for better readability.")

(defconst themes-doom-1337-modeline-bg "#4a4a4a" "Modeline background - medium gray.")

(defconst
 themes-doom-1337-modeline-inactive-bg "#3a3a3a" "Inactive modeline background - darker gray.")

(defconst themes-doom-1337-modeline-fg "#d0d0d0" "Default modeline foreground - light gray.")

;; IMPORTANT: For consistent color rendering across local and remote (SSH) sessions,
;; ensure COLORTERM=truecolor is set in your shell configuration:
;;   - Add to ~/.bashrc or ~/.zshrc: export COLORTERM=truecolor
;;   - Without this setting, colors may appear differently when using Emacs over SSH
;;   - These RGB color values (#rrggbb) require 24-bit true color terminal support
(defconst themes-doom-1337-color-cyan "#00ff9f" "Primary accent - bright cyan-green.")

(defconst themes-doom-1337-color-purple "#d77dd7" "Secondary accent - bright magenta.")

(defconst themes-doom-1337-color-blue "#5fb3f0" "Tertiary accent - brightened blue.")

(defconst themes-doom-1337-color-orange "#ffb347" "Warnings - brightened orange.")

(defconst themes-doom-1337-color-red "#f0a0a0" "Errors - light coral red for contrast.")

(defconst themes-doom-1337-color-yellow "#ffe66d" "Modified/attention - yellow.")

(defconst themes-doom-1337-color-green "#7bc275" "Success - green.")

(defconst themes-doom-1337-color-teal "#7dd0d0" "Info/time - soft cyan-teal.")

(defconst themes-doom-1337-color-light-gray "#d0d0d0" "Light text - brightened gray.")

(defconst themes-doom-1337-color-dim-gray "#a0a0a0" "Dim text - medium gray.")

(defconst
 themes-doom-1337-search-highlight-color
 themes-doom-1337-color-green
 "Search match highlighting - used by isearch, `query-replace', and orderless.")

;; Parenthesis Matching Colors (show-paren-mode)
(defconst
 themes-doom-1337-paren-match-bg
 "#00CED1"
 "Matching parenthesis background - bright dark turquoise.")

(defconst
 themes-doom-1337-paren-match-fg "#000000" "Matching parenthesis foreground - black for contrast.")

(defconst
 themes-doom-1337-paren-mismatch-bg
 "#FF0000"
 "Mismatched parenthesis background - pure bright red for error visibility.")

(defconst
 themes-doom-1337-paren-mismatch-fg
 "#FFFF00"
 "Mismatched parenthesis foreground - bright yellow for maximum contrast.")
(provide 'themes-doom-1337-constants)
;;; themes-doom-1337-constants.el ends here
