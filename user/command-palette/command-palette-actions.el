;;; command-palette-actions.el --- Command Palette Actions and Utilities -*- lexical-binding: t -*-
;;; Commentary:
;; User actions and utility functions for command palette.
;; Handles command execution, history tracking, and user-triggered actions.

;;; Code:
(require 'command-palette-init)
(require 'core-user-interaction-utils)
(require 'logging-init)
(require 'ring)
(require 'cl-lib)

;; Forward declaration
(declare-function command-palette--refresh-buffer "command-palette-views")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Utility Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 command-palette--format-command-name (cmd-symbol)
 "Convert CMD-SYMBOL to human-readable format.
Example: \\='find-file\\=' becomes \\='Find File\\='."
 (let ((name (symbol-name cmd-symbol)))
   (capitalize (replace-regexp-in-string "-" " " name))))

(defun
 command-palette--get-keybinding
 (cmd-symbol)
 "Get the first keybinding for CMD-SYMBOL as a string, or nil if none exists."
 (when
  (commandp cmd-symbol)
  (let ((keys (where-is-internal cmd-symbol nil t)))
    (when keys (key-description keys)))))

(defun
 command-palette--add-to-history (cmd-symbol)
 "Add CMD-SYMBOL to command history if it's not excluded or in favorites.
Removes any existing occurrences before adding to ensure no duplicates.  Returns t if added, nil if excluded."
 (when
  (and
   (symbolp cmd-symbol)
   (commandp cmd-symbol)
   (not (memq cmd-symbol command-palette-excluded-commands))
   (not
    (assoc
     cmd-symbol
     (mapcar (lambda (item) (cons (cdr item) (car item))) user-command-palette-favorites))))
  (let ((new-ring (make-ring command-palette-history-size))
        (cmd-name (command-palette--format-command-name cmd-symbol))
        (len (ring-length user--command-palette-history)))
    (dotimes
     (i len)
     (let* ((idx (- len 1 i))
            (item (ring-ref user--command-palette-history idx)))
       (unless (eq (cdr item) cmd-symbol) (ring-insert new-ring item))))
    (setq user--command-palette-history new-ring)
    (ring-insert user--command-palette-history (cons cmd-name cmd-symbol))
    (command-palette--refresh-buffer)
    t)))

(defun
 command-palette--execute-command (cmd-symbol)
 "Execute command CMD-SYMBOL.
Switches to the previous window before executing the command, then closes the palette."
 (command-palette--add-to-history cmd-symbol)
 (when
  (and user-command-palette-window (window-live-p user-command-palette-window))
  (delete-window user-command-palette-window)
  (setq user-command-palette-window nil))
 (let ((target-window
        (or
         (and
          user--command-palette-previous-window
          (window-live-p user--command-palette-previous-window)
          user--command-palette-previous-window)
         (cl-find-if
          (lambda
           (win) (not (string= (buffer-name (window-buffer win)) command-palette-buffer-name)))
          (window-list)))))
   (when target-window (select-window target-window))
   (call-interactively cmd-symbol)))

(defun
 command-palette--make-button (label action face &optional keybinding)
 "Create a clickable button with LABEL that execute ACTION.  Use FACE for styling.
If KEYBINDING is provided, display it in parentheses with a red color."
 (let ((start (point)))
   (insert label)
   (make-text-button
    start
    (point)
    'action
    action
    'follow-link
    t
    'face
    face
    'help-echo
    (format "Click to execute: %s" label))
   (when
    keybinding
    (insert " ")
    (insert (propertize (format "(%s)" keybinding) 'face '(:foreground "#e74c3c"))))))

(defun
 command-palette--calculate-window-width ()
 "Calculate window width based on longest line in current buffer.
Returns width as number of columns needed to display content."
 (save-excursion
  (goto-char (point-min))
  (let ((max-width 0))
    (while
     (not (eobp))
     (let ((line-width (- (line-end-position) (line-beginning-position))))
       (setq max-width (max max-width line-width)))
     (forward-line 1))
    (+ max-width 2))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Action Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 command-palette--add-favorite ()
 "Promote a recent command from history to the favorites list.

Prompts for an index number from the recent commands list, then adds that
command to the favorites section.  The command remains in history.
The favorites list is persisted to disk immediately."
 (interactive)
 (if
  (= (ring-length user--command-palette-history) 0)
  (logging-warning "No recent commands to promote.  Execute commands via M-x first.")
  (let* ((max-index (ring-length user--command-palette-history))
         (index
          (core-user-read-number
           (format "Promote recent command to favorites (1 - %d): " max-index) 1 max-index)))
    (if
     index
     (let* ((item (ring-ref user--command-palette-history (1- index)))
            (cmd-name (car item))
            (cmd-symbol (cdr item)))
       (unless
        (assoc cmd-name user-command-palette-favorites)
        (add-to-list 'user-command-palette-favorites item t)
        (command-palette--refresh-buffer)
        (logging-success "Promoted #%d '%s' to favorites (kept in history)" index cmd-name)))
     (logging-warning "Invalid index or cancelled")))))

(defun
 command-palette--add-favorite-from-diagnostics ()
 "Promote a diagnostic command to the favorites list.

Prompts for an index number from the diagnostics list, then adds that
command to the favorites section.  The command remains in diagnostics.
The favorites list is persisted to disk immediately."
 (interactive)
 (if
  (= (length user-command-palette-diagnostics) 0)
  (logging-warning "No diagnostic commands to promote.")
  (let* ((max-index (length user-command-palette-diagnostics))
         (index
          (core-user-read-number
           (format "Promote diagnostic to favorites (1 - %d): " max-index) 1 max-index)))
    (if
     index
     (let* ((item (nth (1- index) user-command-palette-diagnostics))
            (cmd-name (car item))
            (cmd-symbol (cdr item)))
       (unless
        (assoc cmd-name user-command-palette-favorites)
        (add-to-list 'user-command-palette-favorites item t)
        (command-palette--refresh-buffer)
        (logging-success "Promoted #%d '%s' to favorites (kept in diagnostics)" index cmd-name)))
     (logging-warning "Invalid index or cancelled")))))

(defun
 command-palette--remove-favorite ()
 "Remove a command from the favorites list by index number.

Prompts for an index number from the favorites list, then permanently removes
that command from favorites.  The change is persisted to disk immediately.
Does not affect the command's availability in `M-x'."
 (interactive)
 (if
  (= (length user-command-palette-favorites) 0) (logging-warning "No favorites to remove")
  (let* ((max-index (length user-command-palette-favorites))
         (index
          (core-user-read-number
           (format "Remove favorite by index (1 - %d): " max-index) 1 max-index)))
    (if
     index
     (let* ((item-to-remove (nth (1- index) user-command-palette-favorites))
            (cmd-name (car item-to-remove)))
       (setq
        user-command-palette-favorites (cl-remove item-to-remove user-command-palette-favorites))
       (command-palette--refresh-buffer)
       (logging-success "Removed favorite #%d: '%s'" index cmd-name))
     (logging-warning "Invalid index or cancelled")))))

(defun
 command-palette--clear-history
 ()
 "Clear all recent commands from the command palette history.

Removes all entries from the recent commands section while preserving favorites.
Use this to reset your recent commands list while keeping your favorites intact."
 (interactive)
 (setq user--command-palette-history (make-ring command-palette-history-size))
 (command-palette--refresh-buffer)
 (logging-success "Command palette history cleared"))

(defun
 command-palette--validate-commands
 ()
 "Validate all commands in favorites, diagnostics, and history, removing any that no longer exist."
 (interactive)
 (let ((removed-favorites 0)
       (removed-diagnostics 0)
       (removed-history 0))
   (let ((valid-favorites nil))
     (dolist
      (item user-command-palette-favorites)
      (let ((cmd-symbol (cdr item))
            (cmd-name (car item)))
        (if
         (and (fboundp cmd-symbol) (commandp cmd-symbol)) (push item valid-favorites)
         (progn
          (setq removed-favorites (1+ removed-favorites))
          (logging-warning "Removed invalid favorite: %s (%s)" cmd-name cmd-symbol)))))
     (setq user-command-palette-favorites (nreverse valid-favorites)))
   (let ((valid-diagnostics nil))
     (dolist
      (item user-command-palette-diagnostics)
      (let ((cmd-symbol (cdr item))
            (cmd-name (car item)))
        (if
         (and (fboundp cmd-symbol) (commandp cmd-symbol)) (push item valid-diagnostics)
         (progn
          (setq removed-diagnostics (1+ removed-diagnostics))
          (logging-warning "Removed invalid diagnostic: %s (%s)" cmd-name cmd-symbol)))))
     (setq user-command-palette-diagnostics (nreverse valid-diagnostics)))
   (let ((new-ring (make-ring command-palette-history-size))
         (len (ring-length user--command-palette-history)))
     (dotimes
      (i len)
      (let* ((idx (- len 1 i))
             (item (ring-ref user--command-palette-history idx))
             (cmd-symbol (cdr item))
             (cmd-name (car item)))
        (if
         (and (fboundp cmd-symbol) (commandp cmd-symbol)) (ring-insert new-ring item)
         (progn
          (setq removed-history (1+ removed-history))
          (logging-warning "Removed invalid history item: %s (%s)" cmd-name cmd-symbol)))))
     (setq user--command-palette-history new-ring))
   (command-palette--refresh-buffer)
   (if
    (and (= removed-favorites 0) (= removed-diagnostics 0) (= removed-history 0))
    (logging-success "All commands are valid")
    (logging-success
     "Validation complete: removed %d favorite(s), %d diagnostic(s), and %d history item(s)"
     removed-favorites
     removed-diagnostics
     removed-history))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Tracking Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 command-palette--track-command () "Track commands executed via `M-x' using `post-command-hook'."
 (when
  (memq this-command '(execute-extended-command execute-extended-command-for-buffer))
  (setq user--command-palette-mx-flag t))
 (when
  (and
   user--command-palette-mx-flag this-command (commandp this-command)
   (not
    (memq this-command '(execute-extended-command execute-extended-command-for-buffer)))
   (not (memq this-command command-palette-excluded-commands)))
  (command-palette--add-to-history this-command) (setq user--command-palette-mx-flag nil)))

(provide 'command-palette-actions)
;;; command-palette-actions.el ends here
