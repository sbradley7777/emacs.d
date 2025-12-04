;;; command-palette-sections.el --- Command Palette Section Rendering -*- lexical-binding: t -*-
;;; Commentary:
;; Section configuration and rendering functions for command palette.
;; Defines section types (Actions, Navigation, Commands) and provides
;; generic rendering infrastructure.

;;; Code:
(require 'command-palette-init)
(require 'command-palette-constants)
(require 'command-palette-actions)
(require 'ring)

;; Forward declarations
(declare-function command-palette--get-keybinding "command-palette-actions")
(declare-function command-palette--execute-command "command-palette-actions")
(declare-function command-palette-switch-to-favorites "command-palette-views")
(declare-function command-palette-switch-to-diagnostics "command-palette-views")
(declare-function command-palette-switch-to-history "command-palette-views")
(declare-function command-palette-next-view "command-palette-views")
(declare-function command-palette-previous-view "command-palette-views")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Action Button Definitions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defconst
 command-palette--action-buttons
 '(favorites
   ((:label
     "Remove Favorite by Index"
     :key "r"
     :function command-palette--remove-favorite
     :face command-palette--color-action-remove
     :call-type interactive
     :enabled t)
    (:label
     "Validate Commands"
     :key "v"
     :function command-palette--validate-commands
     :face command-palette--color-action-validate
     :call-type direct
     :enabled t)
    (:label
     "Close Palette"
     :key "q"
     :function toggle-command-palette
     :face command-palette--color-action-close
     :call-type direct
     :enabled t))
   diagnostics
   ((:label
     "Promote to Favorites"
     :key "a"
     :function command-palette--add-favorite-from-diagnostics
     :face command-palette--color-action-add
     :call-type interactive
     :enabled t)
    (:label
     "Validate Commands"
     :key "v"
     :function command-palette--validate-commands
     :face command-palette--color-action-validate
     :call-type direct
     :enabled t)
    (:label
     "Close Palette"
     :key "q"
     :function toggle-command-palette
     :face command-palette--color-action-close
     :call-type direct
     :enabled t))
   history
   ((:label
     "Promote to Favorites"
     :key "a"
     :function command-palette--add-favorite
     :face command-palette--color-action-add
     :call-type interactive
     :enabled t)
    (:label
     "Clear History"
     :key "c"
     :function command-palette--clear-history
     :face command-palette--color-action-clear
     :call-type direct
     :enabled t)
    (:label
     "Close Palette"
     :key "q"
     :function toggle-command-palette
     :face command-palette--color-action-close
     :call-type direct
     :enabled t)))
 "Action button definitions for each view.
Format: (view-key ((button-plist) ...))
Each button has:
  :label      - Display text
  :key        - Single character keybinding
  :function   - Function to execute
  :face       - Face constant for button styling
  :call-type  - \\='interactive or \\='direct
  :enabled    - t to show, nil to hide (future: could be predicate function)")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Navigation Button Definitions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defconst
 command-palette--navigation-buttons
 '((:label
    "Favorites"
    :key "f"
    :view favorites
    :function command-palette-switch-to-favorites
    :enabled t)
   (:label
    "Diagnostics"
    :key "d"
    :view diagnostics
    :function command-palette-switch-to-diagnostics
    :enabled t)
   (:label
    "History"
    :key "h"
    :view history
    :function command-palette-switch-to-history
    :enabled t))
 "Navigation button definitions for switching between views.
Each button has:
  :label     - Display text
  :key       - Single character keybinding
  :view      - View symbol this button switches to
  :function  - Function to execute
  :enabled   - t to show, nil to hide")

(defconst
 command-palette--navigation-controls
 '(:previous
   (:label "← Previous" :key "p" :function command-palette-previous-view :enabled t)
   :next (:label "Next →" :key "n" :function command-palette-next-view :enabled t))
 "Navigation control definitions for prev/next view cycling.
Format: (:direction plist)
Each control has:
  :label     - Display text
  :key       - Single character keybinding
  :function  - Function to execute
  :enabled   - t to show, nil to hide")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Section Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defconst
 command-palette--section-order
 '(:actions :navigation :commands)
 "Order in which sections are rendered in the command palette.")

(defconst
 command-palette--section-configs
 '(:actions
   (:header
    "⚙️  Actions\n"
    :separator horizontal
    :render-function command-palette--render-action-section-content
    :add-leading-newline t)
   :navigation
   (:header
    "🧭 Navigation\n"
    :separator horizontal
    :render-function command-palette--render-navigation-section-content
    :add-leading-newline t)
   :commands
   (:header
    nil
    :separator horizontal
    :render-function command-palette--render-command-list-section-content
    :add-leading-newline t))
 "Configuration for each section type.
Properties:
  :header              - Section header text (can be nil if view-specific)
  :separator           - Type of separator (horizontal, box, or nil)
  :render-function     - Function to render section content
  :add-leading-newline - Add newline before section")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Section Helper Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 command-palette--render-section-separator () "Render a horizontal section separator line."
 (let ((separator-line
        (concat
         (make-string
          command-palette--border-width command-palette--char-horizontal-single)
         "\n")))
   (insert (propertize separator-line 'face command-palette--color-border))))


(defun
 command-palette--iterate-data (data data-type callback)
 "Call CALLBACK for each item in DATA, handling both ring and list types.
CALLBACK is called with two arguments: (item index) for each element.
For ring data, iteration starts from oldest to newest."
 (if
  (eq data-type 'ring) (dotimes (i (ring-length data)) (funcall callback (ring-ref data i) i))
  (let ((index 0))
    (dolist (item data) (funcall callback item index) (setq index (1+ index))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Section Rendering Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 command-palette--render-action-section-content (view-config)
 "Render action section content for current view using VIEW-CONFIG.
Looks up actions from `command-palette--action-buttons' based on current view."
 (let* ((view-key user--command-palette-current-view)
        (actions (plist-get command-palette--action-buttons view-key)))
   (dolist
    (action actions)
    (let ((enabled (plist-get action :enabled)))
      (when
       enabled
       (let* ((label (plist-get action :label))
              (key (plist-get action :key))
              (func (plist-get action :function))
              (face (symbol-value (plist-get action :face)))
              (call-type (plist-get action :call-type)))
         (insert command-palette--format-bullet)
         (command-palette--make-button
          label
          (if
           (eq call-type 'interactive)
           (lambda (_) (call-interactively func))
           (lambda (_) (funcall func)))
          face)
         (let* ((bullet-len (length command-palette--format-bullet))
                (label-len (length label))
                (key-text (format command-palette--format-key key))
                (key-len (length key-text))
                (spacing (- command-palette--border-width bullet-len label-len key-len)))
           (insert (make-string spacing ?\s))
           (insert (propertize key-text 'face command-palette--color-key)))
         (insert "\n")))))))

(defun
 command-palette--render-navigation-section-content (_view-config)
 "Render navigation section content with view buttons and prev/next navigation.
_VIEW-CONFIG is unused but required for section renderer interface."
 (dolist
  (nav-button command-palette--navigation-buttons)
  (when
   (plist-get nav-button :enabled)
   (let* ((label (plist-get nav-button :label))
          (key (plist-get nav-button :key))
          (func (plist-get nav-button :function)))
     (insert command-palette--format-bullet)
     (command-palette--make-button
      label (lambda (_) (funcall func)) command-palette--color-navigation)
     (let* ((bullet-len (length command-palette--format-bullet))
            (label-len (length label))
            (key-text (format command-palette--format-key key))
            (key-len (length key-text))
            (spacing (- command-palette--border-width bullet-len label-len key-len)))
       (insert (make-string spacing ?\s))
       (insert (propertize key-text 'face command-palette--color-key)))
     (insert "\n"))))
 (insert "\n")
 (let* ((prev-config (plist-get command-palette--navigation-controls :previous))
        (next-config (plist-get command-palette--navigation-controls :next))
        (prev-enabled (plist-get prev-config :enabled))
        (next-enabled (plist-get next-config :enabled))
        (prev-label (plist-get prev-config :label))
        (prev-key (plist-get prev-config :key))
        (prev-func (plist-get prev-config :function))
        (next-label (plist-get next-config :label))
        (next-key (plist-get next-config :key))
        (next-func (plist-get next-config :function))
        (prev-text
         (when
          prev-enabled (format "%s %s" prev-label (format command-palette--format-key prev-key))))
        (next-text
         (when
          next-enabled (format "%s %s" (format command-palette--format-key next-key) next-label))))
   (when
    prev-enabled
    (command-palette--make-button
     prev-text (lambda (_) (funcall prev-func)) command-palette--color-navigation))
   (when
    (and prev-enabled next-enabled)
    (let ((spacing (- command-palette--border-width (length prev-text) (length next-text))))
      (insert (make-string spacing ?\s))))
   (when
    next-enabled
    (command-palette--make-button
     next-text (lambda (_) (funcall next-func)) command-palette--color-navigation)))
 (insert "\n"))

(defun
 command-palette--render-command-list-section-content (view-config)
 "Render command list section content using VIEW-CONFIG.
Returns the position of the first command button, or nil if no commands."
 (let* ((data-var (plist-get view-config :data-var))
        (data-type (plist-get view-config :data-type))
        (empty-msg (plist-get view-config :empty-msg))
        (button-color (symbol-value (plist-get view-config :button-color)))
        (data (symbol-value data-var))
        (first-button-pos nil))
   (if
    (if (eq data-type 'ring) (= (ring-length data) 0) (= (length data) 0))
    (insert (propertize empty-msg 'face command-palette--color-empty))
    (let ((display-index 1))
      (command-palette--iterate-data
       data data-type
       (lambda
        (item _idx)
        (let* ((name (car item))
               (cmd (cdr item))
               (keybinding (command-palette--get-keybinding cmd))
               (button-start (point)))
          (when (= display-index 1) (setq first-button-pos button-start))
          (command-palette--make-button
           (format command-palette--format-command display-index name)
           (lambda (_) (command-palette--execute-command cmd))
           button-color
           keybinding)
          (insert "\n")
          (setq display-index (1+ display-index)))))))
   first-button-pos))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Generic Section Renderer
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 command-palette--render-section (section-key view-config)
 "Render a section based on SECTION-KEY using VIEW-CONFIG.
Returns value from render function (used for cursor positioning in commands section)."
 (let* ((section-config (plist-get command-palette--section-configs section-key))
        (header
         (or
          (plist-get section-config :header)
          (when (eq section-key :commands) (plist-get view-config :header))))
        (separator (plist-get section-config :separator))
        (render-fn (plist-get section-config :render-function))
        (leading-newline (plist-get section-config :add-leading-newline))
        (trailing-newline (plist-get section-config :add-trailing-newline))
        (result nil))
   (when leading-newline (insert "\n"))
   (when header (insert (propertize header 'face command-palette--color-header)))
   (when (eq separator 'horizontal) (command-palette--render-section-separator))
   (setq result (funcall render-fn view-config))
   (when trailing-newline (insert "\n"))
   result))

(provide 'command-palette-sections)
;;; command-palette-sections.el ends here
