;;; command-palette-constants.el --- Command Palette Constants -*- lexical-binding: t -*-
;;; Commentary:
;; Constants used across the command palette system.

;;; Code:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Display Constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defconst command-palette--border-width 40 "Width of command palette borders.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Border Character Constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defconst command-palette--char-top-left ?╔ "Top-left corner character for borders.")
(defconst command-palette--char-top-right ?╗ "Top-right corner character for borders.")
(defconst command-palette--char-vertical ?║ "Vertical line character for borders.")
(defconst command-palette--char-bottom-left ?╚ "Bottom-left corner character for borders.")
(defconst command-palette--char-bottom-right ?╝ "Bottom-right corner character for borders.")
(defconst command-palette--char-left-tee ?╠ "Left tee character for separators.")
(defconst command-palette--char-right-tee ?╣ "Right tee character for separators.")
(defconst command-palette--char-horizontal-double ?═ "Double horizontal line character.")
(defconst command-palette--char-horizontal-single ?─ "Single horizontal line character.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Color Palette Constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defconst
 command-palette--color-border '(:foreground "green") "Face properties for border elements.")
(defconst
 command-palette--color-title
 '(:weight bold :foreground "green")
 "Face properties for title text.")
(defconst
 command-palette--color-header
 '(:weight bold :foreground "green")
 "Face properties for section headers.")
(defconst
 command-palette--color-key '(:foreground "#e74c3c") "Face properties for keybinding text.")
(defconst
 command-palette--color-empty
 '(:foreground "gray" :slant italic)
 "Face properties for empty message text.")
(defconst
 command-palette--color-button-favorites
 '(:foreground "lightgreen")
 "Face properties for Favorites view command buttons.")
(defconst
 command-palette--color-button-diagnostics
 '(:foreground "yellow")
 "Face properties for Diagnostics view command buttons.")
(defconst
 command-palette--color-button-history
 '(:foreground "orange")
 "Face properties for History view command buttons.")
(defconst
 command-palette--color-action-remove
 '(:foreground "red")
 "Face properties for remove favorite action button.")
(defconst
 command-palette--color-action-add
 '(:foreground "cyan")
 "Face properties for add favorite action button.")
(defconst
 command-palette--color-action-validate
 '(:foreground "lightblue")
 "Face properties for validate commands action button.")
(defconst
 command-palette--color-action-clear
 '(:foreground "yellow")
 "Face properties for clear history action button.")
(defconst
 command-palette--color-action-close
 '(:foreground "gray")
 "Face properties for close palette action button.")
(defconst
 command-palette--color-navigation
 '(:foreground "yellow")
 "Face properties for navigation buttons.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Formatting Constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defconst command-palette--format-bullet " • " "Bullet prefix for action and navigation items.")
(defconst command-palette--format-key "(%s)" "Format string for keybinding display.")
(defconst command-palette--format-command "  %2d. %s" "Format string for command list items.")
(defconst command-palette--regex-label-key "\\(.*\\) (\\(.\\))$" "Regex to extract label and key.")
(defconst command-palette--regex-key-only "(\\(.\\))$" "Regex to extract key only.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Message String Constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defconst
 command-palette--msg-invalid-index "Invalid index or cancelled" "Message for invalid index.")
(defconst
 command-palette--msg-no-items
 "No %s to %s"
 "Message format for empty source. Args: source-name, action.")
(defconst
 command-palette--msg-promoted
 "Promoted #%d '%s' to favorites (kept in %s)"
 "Message format for successful promotion. Args: index, name, source.")
(defconst
 command-palette--msg-removed
 "Removed %s #%d: '%s'"
 "Message format for successful removal. Args: type, index, name.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Data Persistence Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defconst
 command-palette--persistence-configs
 '((history
    :variable user--command-palette-history
    :saved-var command-palette-saved-history
    :file command-palette-history-file
    :data-type ring
    :description "execution history"
    :default nil)
   (favorites
    :variable user-command-palette-favorites
    :saved-var command-palette-saved-favorites
    :file command-palette-favorites-file
    :data-type list
    :description "favorites list"
    :default command-palette-default-favorites)
   (diagnostics
    :variable user-command-palette-diagnostics
    :saved-var command-palette-saved-diagnostics
    :file command-palette-diagnostics-file
    :data-type list
    :description "diagnostics list"
    :default command-palette-default-diagnostics))
 "Configuration for persistent data storage.
Each entry defines:
  :variable     - Runtime variable holding the data
  :saved-var    - Variable name used in saved file
  :file         - File path constant for storage
  :data-type    - Type of data structure (ring or list)
  :description  - Human-readable description
  :default      - Default value constant (or nil for history)")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; View Navigation Constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defconst
 command-palette--default-view 'favorites "Default view to display when opening command palette.")
(defconst
 command-palette--view-order
 '(favorites diagnostics history)
 "Order of views for cycling with next/previous commands.")

(provide 'command-palette-constants)
;;; command-palette-constants.el ends here
