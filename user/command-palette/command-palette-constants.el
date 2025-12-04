;;; command-palette-constants.el --- Command Palette Constants -*- lexical-binding: t -*-
;;; Commentary:
;; Constants used across the command palette system.

;;; Code:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Display Constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defconst command-palette--border-width 40 "Width of command palette borders.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; View Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defconst
 command-palette--view-configs
 '((favorites
    :title "FAVORITES   "
    :data-var user-command-palette-favorites
    :data-type list
    :header "⭐ Commands\n"
    :empty-msg "    (No favorites yet)\n"
    :button-color (:foreground "lightgreen")
    :section-label "⭐ Commands\n"
    :actions
    (("Remove Favorite by Index (r)"
      command-palette--remove-favorite
      (:foreground "red")
      interactive)
     ("Validate Commands (v)"
      command-palette--validate-commands
      (:foreground "lightblue")
      direct)
     ("Close Palette (q)" toggle-command-palette (:foreground "gray") direct)))
   (diagnostics
    :title "DIAGNOSTICS   "
    :data-var user-command-palette-diagnostics
    :data-type list
    :header "🔍 Commands\n"
    :empty-msg "    (No diagnostics configured)\n"
    :button-color (:foreground "yellow")
    :section-label "🔍 Commands\n"
    :actions
    (("Promote to Favorites (a)"
      command-palette--add-favorite-from-diagnostics
      (:foreground "cyan")
      interactive)
     ("Validate Commands (v)"
      command-palette--validate-commands
      (:foreground "lightblue")
      direct)
     ("Close Palette (q)" toggle-command-palette (:foreground "gray") direct)))
   (history
    :title "HISTORY   "
    :data-var user--command-palette-history
    :data-type ring
    :header "🕐 Commands\n"
    :empty-msg "    (No recent commands)\n"
    :button-color (:foreground "orange")
    :section-label "🕐 Commands\n"
    :actions
    (("Promote to Favorites (a)" command-palette--add-favorite (:foreground "cyan") interactive)
     ("Clear History (c)" command-palette--clear-history (:foreground "yellow") direct)
     ("Close Palette (q)" toggle-command-palette (:foreground "gray") direct))))
 "Configuration alist defining properties for each view.
Each view configuration contains:
  :title         - Display title for the view
  :data-var      - Symbol of variable holding the data
  :data-type     - Type of data (list or ring)
  :header        - Header text for command list section
  :empty-msg     - Message when no commands available
  :button-color  - Face properties for command buttons
  :section-label - Label for the command list section
  :actions       - List of action buttons (label function face call-type)")

(provide 'command-palette-constants)
;;; command-palette-constants.el ends here
