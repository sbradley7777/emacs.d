;;; command-palette-views.el --- Command Palette View Rendering and Navigation -*- lexical-binding: t -*-
;;; Commentary:
;; View rendering and navigation functions for command palette.
;; Handles switching between Favorites, Diagnostics, and History views.

;;; Code:
(require 'command-palette-init)
(require 'command-palette-constants)
(require 'logging-init)
(require 'ring)

;; Forward declarations
(declare-function command-palette--make-button "command-palette-actions")
(declare-function command-palette--get-keybinding "command-palette-actions")
(declare-function command-palette--execute-command "command-palette-actions")
(declare-function command-palette--add-favorite "command-palette-actions")
(declare-function command-palette--add-favorite-from-diagnostics "command-palette-actions")
(declare-function command-palette--remove-favorite "command-palette-actions")
(declare-function command-palette--clear-history "command-palette-actions")
(declare-function command-palette--validate-commands "command-palette-actions")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Navigation Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 command-palette-switch-to-favorites
 ()
 "Switch command palette to Favorites view."
 (interactive)
 (setq user--command-palette-current-view 'favorites)
 (command-palette--refresh-buffer)
 (logging-info "Switched to Favorites view"))

(defun
 command-palette-switch-to-diagnostics
 ()
 "Switch command palette to Diagnostics view."
 (interactive)
 (setq user--command-palette-current-view 'diagnostics)
 (command-palette--refresh-buffer)
 (logging-info "Switched to Diagnostics view"))

(defun
 command-palette-switch-to-history
 ()
 "Switch command palette to History view."
 (interactive)
 (setq user--command-palette-current-view 'history)
 (command-palette--refresh-buffer)
 (logging-info "Switched to History view"))

(defun
 command-palette-next-view
 ()
 "Switch to next view in cycle: Favorites → Diagnostics → History → Favorites."
 (interactive)
 (setq
  user--command-palette-current-view
  (pcase user--command-palette-current-view
    ('favorites 'diagnostics)
    ('diagnostics 'history)
    ('history 'favorites)))
 (command-palette--refresh-buffer))

(defun
 command-palette-previous-view
 ()
 "Switch to previous view in cycle: Favorites → History → Diagnostics → Favorites."
 (interactive)
 (setq
  user--command-palette-current-view
  (pcase user--command-palette-current-view
    ('favorites 'history)
    ('history 'diagnostics)
    ('diagnostics 'favorites)))
 (command-palette--refresh-buffer))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Rendering Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 command-palette--render-top-border (title) "Render top border with TITLE."
 (let ((border-line (concat "╔" (make-string (- command-palette--border-width 2) ?═) "╗\n")))
   (insert (propertize border-line 'face '(:foreground "green"))))
 (let* ((title-len (length title))
        (total-width (- command-palette--border-width 2))
        (left-padding (/ (- total-width title-len) 2))
        (right-padding (- total-width title-len left-padding))
        (line
         (format
          "║%s%s%s║\n" (make-string left-padding ?\s) title (make-string right-padding ?\s))))
   (insert (propertize line 'face '(:weight bold :foreground "green")))))
(defun
 command-palette--render-bottom-border () "Render bottom border."
 (let ((border-line (concat "╚" (make-string (- command-palette--border-width 2) ?═) "╝\n")))
   (insert (propertize border-line 'face '(:foreground "green")))))
(defun
 command-palette--render-separator () "Render a section separator line."
 (let ((separator-line (concat "╠" (make-string (- command-palette--border-width 2) ?═) "╣\n")))
   (insert (propertize separator-line 'face '(:foreground "green")))))
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
 command-palette--render-action-section (actions)
 "Render action section with ACTIONS list.
Each action is (LABEL FUNCTION FACE CALL-TYPE)."
 (insert (propertize "⚙️  Actions\n" 'face '(:weight bold :foreground "green")))
 (let ((separator-line (concat (make-string command-palette--border-width ?─) "\n")))
   (insert (propertize separator-line 'face '(:foreground "green"))))
 (dolist
  (action actions)
  (let ((label (nth 0 action))
        (func (nth 1 action))
        (face (nth 2 action))
        (call-type (nth 3 action)))
    (insert " • ")
    (command-palette--make-button
     label
     (if
      (eq call-type 'interactive)
      (lambda (_) (call-interactively func))
      (lambda (_) (funcall func)))
     face)
    (insert "\n"))))

(defun
 command-palette--render-views-section
 ()
 "Render views navigation section with bullet list and prev/next buttons."
 (insert "\n")
 (insert (propertize "🧭 Navigation\n" 'face '(:weight bold :foreground "green")))
 (let ((separator-line (concat (make-string command-palette--border-width ?─) "\n")))
   (insert (propertize separator-line 'face '(:foreground "green"))))
 (insert " • ")
 (let ((start (point)))
   (insert "Favorites (f)")
   (make-text-button
    start
    (point)
    'action
    (lambda (_) (command-palette-switch-to-favorites))
    'follow-link
    t
    'face
    '(:foreground "yellow")))
 (insert "\n")
 (insert " • ")
 (let ((start (point)))
   (insert "Diagnostics (d)")
   (make-text-button
    start
    (point)
    'action
    (lambda (_) (command-palette-switch-to-diagnostics))
    'follow-link
    t
    'face
    '(:foreground "yellow")))
 (insert "\n")
 (insert " • ")
 (let ((start (point)))
   (insert "History (h)")
   (make-text-button
    start
    (point)
    'action
    (lambda (_) (command-palette-switch-to-history))
    'follow-link
    t
    'face
    '(:foreground "yellow")))
 (insert "\n\n")
 (let ((start (point)))
   (insert "← Previous (p)")
   (make-text-button
    start
    (point)
    'action
    (lambda (_) (command-palette-previous-view))
    'follow-link
    t
    'face
    '(:foreground "yellow")))
 (let* ((prev-text "← Previous (p)")
        (next-text "Next (n) →")
        (total-width command-palette--border-width)
        (prev-len (length prev-text))
        (next-len (length next-text))
        (spacing (- total-width prev-len next-len)))
   (insert (make-string spacing ?\s)))
 (let ((start (point)))
   (insert "Next (n) →")
   (make-text-button
    start
    (point)
    'action
    (lambda (_) (command-palette-next-view))
    'follow-link
    t
    'face
    '(:foreground "yellow")))
 (insert "\n"))

(defun
 command-palette--render-command-list-section (config)
 "Render command list section using view CONFIG.
CONFIG is a plist from `command-palette--view-configs'.
Returns the position of the first command button, or nil if no commands."
 (let* ((data-var (plist-get config :data-var))
        (data-type (plist-get config :data-type))
        (header (plist-get config :header))
        (empty-msg (plist-get config :empty-msg))
        (button-color (plist-get config :button-color))
        (data (symbol-value data-var))
        (first-button-pos nil))
   (insert "\n")
   (insert (propertize header 'face '(:weight bold :foreground "green")))
   (let ((separator-line (concat (make-string command-palette--border-width ?─) "\n")))
     (insert (propertize separator-line 'face '(:foreground "green"))))
   (if
    (if (eq data-type 'ring) (= (ring-length data) 0) (= (length data) 0))
    (insert (propertize empty-msg 'face '(:foreground "gray" :slant italic)))
    (let ((index 1))
      (if
       (eq data-type 'ring)
       (dotimes
        (i (ring-length data))
        (let* ((item (ring-ref data i))
               (name (car item))
               (cmd (cdr item))
               (keybinding (command-palette--get-keybinding cmd))
               (button-start (point)))
          (when (= index 1) (setq first-button-pos button-start))
          (command-palette--make-button
           (format "  %2d. %s" index name)
           `(lambda (_) (command-palette--execute-command ',cmd))
           button-color
           keybinding)
          (insert "\n")
          (setq index (1+ index))))
       (dolist
        (item data)
        (let* ((name (car item))
               (cmd (cdr item))
               (keybinding (command-palette--get-keybinding cmd))
               (button-start (point)))
          (when (= index 1) (setq first-button-pos button-start))
          (command-palette--make-button
           (format "  %2d. %s" index name)
           `(lambda (_) (command-palette--execute-command ',cmd))
           button-color
           keybinding)
          (insert "\n")
          (setq index (1+ index)))))))
   (insert "\n")
   first-button-pos))

(defun
 command-palette--render-view (view-name)
 "Render a single view using VIEW-NAME configuration.
Returns the position of the first command button, or nil if no commands."
 (let ((config (cdr (assoc view-name command-palette--view-configs))))
   (when
    config
    (let ((title (plist-get config :title))
          (actions (plist-get config :actions)))
      (command-palette--render-top-border title)
      (command-palette--render-separator)
      (command-palette--render-action-section actions)
      (command-palette--render-views-section)
      (let ((first-cmd-pos (command-palette--render-command-list-section config)))
        (command-palette--render-bottom-border)
        first-cmd-pos)))))

(defun
 command-palette--render-content
 ()
 "Render the command palette buffer content based on current view."
 (pcase user--command-palette-current-view
   ('favorites (command-palette--render-view 'favorites))
   ('diagnostics (command-palette--render-view 'diagnostics))
   ('history (command-palette--render-view 'history))
   (_ (command-palette--render-view 'favorites))))

(provide 'command-palette-views)
;;; command-palette-views.el ends here
