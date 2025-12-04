;;; command-palette-views.el --- Command Palette View Rendering and Navigation -*- lexical-binding: t -*-
;;; Commentary:
;; View configuration, navigation, and high-level rendering for command palette.
;; Handles view switching and orchestrates section rendering.

;;; Code:
(require 'command-palette-init)
(require 'command-palette-constants)
(require 'command-palette-sections)
(require 'logging-init)
(require 'cl-lib)

;; Forward declarations
(declare-function command-palette--render-section "command-palette-sections")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; View Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defconst
 command-palette--view-configs
 '((favorites
    :title "FAVORITES   "
    :view-label "Favorites"
    :view-key "f"
    :data-var user-command-palette-favorites
    :data-type list
    :header "⭐ Commands\n"
    :empty-msg "    (No favorites yet)\n"
    :button-color command-palette--color-button-favorites)
   (diagnostics
    :title "DIAGNOSTICS   "
    :view-label "Diagnostics"
    :view-key "d"
    :data-var user-command-palette-diagnostics
    :data-type list
    :header "🔍 Commands\n"
    :empty-msg "    (No diagnostics configured)\n"
    :button-color command-palette--color-button-diagnostics)
   (history
    :title "HISTORY   "
    :view-label "History"
    :view-key "h"
    :data-var user--command-palette-history
    :data-type ring
    :header "🕐 Commands\n"
    :empty-msg "    (No recent commands)\n"
    :button-color command-palette--color-button-history))
 "Configuration alist defining properties for each view.
Each view configuration contains:
  :title         - Display title for the view
  :view-label    - Label for navigation button
  :view-key      - Keybinding letter shown in navigation
  :data-var      - Symbol of variable holding the data
  :data-type     - Type of data (list or ring)
  :header        - Header text for command list section
  :empty-msg     - Message when no commands available
  :button-color  - Face constant for command buttons")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Navigation Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 command-palette--switch-to-view
 (view)
 "Switch command palette to VIEW and refresh buffer."
 (setq user--command-palette-current-view view)
 (command-palette--refresh-buffer))

(defun
 command-palette-switch-to-favorites
 ()
 "Switch command palette to Favorites view."
 (interactive)
 (command-palette--switch-to-view 'favorites)
 (logging-info "Switched to Favorites view"))

(defun
 command-palette-switch-to-diagnostics
 ()
 "Switch command palette to Diagnostics view."
 (interactive)
 (command-palette--switch-to-view 'diagnostics)
 (logging-info "Switched to Diagnostics view"))

(defun
 command-palette-switch-to-history
 ()
 "Switch command palette to History view."
 (interactive)
 (command-palette--switch-to-view 'history)
 (logging-info "Switched to History view"))

(defun
 command-palette-next-view
 ()
 "Switch to next view in cycle: Favorites → Diagnostics → History → Favorites."
 (interactive)
 (let* ((current-idx (cl-position user--command-palette-current-view command-palette--view-order))
        (next-idx (mod (1+ current-idx) (length command-palette--view-order))))
   (setq user--command-palette-current-view (nth next-idx command-palette--view-order))
   (command-palette--refresh-buffer)))

(defun
 command-palette-previous-view
 ()
 "Switch to previous view in cycle: Favorites → History → Diagnostics → Favorites."
 (interactive)
 (let* ((current-idx (cl-position user--command-palette-current-view command-palette--view-order))
        (prev-idx (mod (1- current-idx) (length command-palette--view-order))))
   (setq user--command-palette-current-view (nth prev-idx command-palette--view-order))
   (command-palette--refresh-buffer)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Rendering Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 command-palette--render-top-border (title) "Render top border with TITLE."
 (let ((border-line
        (concat
         (char-to-string command-palette--char-top-left)
         (make-string
          (- command-palette--border-width 2) command-palette--char-horizontal-double)
         (char-to-string command-palette--char-top-right) "\n")))
   (insert (propertize border-line 'face command-palette--color-border)))
 (let* ((title-len (length title))
        (total-width (- command-palette--border-width 2))
        (left-padding (/ (- total-width title-len) 2))
        (right-padding (- total-width title-len left-padding))
        (line
         (format
          "%s%s%s%s%s\n"
          (char-to-string command-palette--char-vertical)
          (make-string left-padding ?\s)
          title
          (make-string right-padding ?\s)
          (char-to-string command-palette--char-vertical))))
   (insert (propertize line 'face command-palette--color-title))))

(defun
 command-palette--render-bottom-border () "Render bottom border."
 (let ((border-line
        (concat
         (char-to-string command-palette--char-bottom-left)
         (make-string
          (- command-palette--border-width 2) command-palette--char-horizontal-double)
         (char-to-string command-palette--char-bottom-right) "\n")))
   (insert (propertize border-line 'face command-palette--color-border))))

(defun
 command-palette--render-separator () "Render a box separator line."
 (let ((separator-line
        (concat
         (char-to-string command-palette--char-left-tee)
         (make-string
          (- command-palette--border-width 2) command-palette--char-horizontal-double)
         (char-to-string command-palette--char-right-tee) "\n")))
   (insert (propertize separator-line 'face command-palette--color-border))))

(defun
 command-palette--refresh-buffer () "Refresh the command palette buffer contents."
 (let ((buffer (get-buffer command-palette-buffer-name)))
   (when
    buffer
    (with-current-buffer
     buffer
     (let ((inhibit-read-only t))
       (erase-buffer)
       (let ((first-cmd-pos (command-palette--render-content)))
         (if first-cmd-pos (goto-char first-cmd-pos) (goto-char (point-min)))))))))

(defun
 command-palette--render-view (view-name)
 "Render a single view using VIEW-NAME configuration.
Returns the position of the first command button, or nil if no commands."
 (let ((config (cdr (assoc view-name command-palette--view-configs))))
   (when
    config
    (let ((title (plist-get config :title))
          (first-cmd-pos nil))
      (command-palette--render-top-border title)
      (command-palette--render-separator)
      (dolist
       (section-key command-palette--section-order)
       (let ((result (command-palette--render-section section-key config)))
         (when (and (eq section-key :commands) result) (setq first-cmd-pos result))))
      (command-palette--render-bottom-border)
      first-cmd-pos))))

(defun
 command-palette--render-content
 ()
 "Render the command palette buffer content based on current view."
 (command-palette--render-view user--command-palette-current-view))

(provide 'command-palette-views)
;;; command-palette-views.el ends here
