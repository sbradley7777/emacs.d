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
   (condition-case err
       (call-interactively cmd-symbol)
     (error
      (logging-error "Command execution failed: %s" (error-message-string err))))))

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
    (+ max-width command-palette--window-padding))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Action Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 command-palette--add-to-favorites-from-source (source-data source-type source-name)
 "Generic function to promote item from SOURCE-DATA to favorites.
SOURCE-DATA is the data structure to promote from.
SOURCE-TYPE is \\='ring or \\='list.
SOURCE-NAME is a string used in user messages (e.g., \"recent command\", \"diagnostic\")."
 (let ((data-length (if (eq source-type 'ring) (ring-length source-data) (length source-data))))
   (if
    (= data-length 0)
    (logging-warning (format command-palette--msg-no-items source-name "promote"))
    (let* ((max-index data-length)
           (index
            (core-user-read-number
             (format "Promote %s to favorites (1 - %d): " source-name max-index) 1 max-index)))
      (if
       index
       (let* ((item
               (if
                (eq source-type 'ring)
                (ring-ref source-data (1- index))
                (nth (1- index) source-data)))
              (cmd-name (car item))
              (cmd-symbol (cdr item)))
         (unless
          (assoc cmd-name user-command-palette-favorites)
          (add-to-list 'user-command-palette-favorites item t)
          (command-palette--refresh-buffer)
          (logging-success (format command-palette--msg-promoted index cmd-name source-name))))
       (logging-warning command-palette--msg-invalid-index))))))

(defun
 command-palette--add-favorite ()
 "Promote a recent command from history to the favorites list.

Prompts for an index number from the recent commands list, then adds that
command to the favorites section.  The command remains in history.
The favorites list is persisted to disk immediately."
 (interactive)
 (command-palette--add-to-favorites-from-source
  user--command-palette-history 'ring "recent command"))

(defun
 command-palette--add-favorite-from-diagnostics ()
 "Promote a diagnostic command to the favorites list.

Prompts for an index number from the diagnostics list, then adds that
command to the favorites section.  The command remains in diagnostics.
The favorites list is persisted to disk immediately."
 (interactive)
 (command-palette--add-to-favorites-from-source
  user-command-palette-diagnostics 'list "diagnostic"))

(defun
 command-palette--remove-favorite ()
 "Remove a command from the favorites list by index number.

Prompts for an index number from the favorites list, then permanently removes
that command from favorites.  The change is persisted to disk immediately.
Does not affect the command's availability in `M-x'."
 (interactive)
 (if
  (= (length user-command-palette-favorites) 0)
  (logging-warning (format command-palette--msg-no-items "favorites" "remove"))
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
       (logging-success (format command-palette--msg-removed "favorite" index cmd-name)))
     (logging-warning command-palette--msg-invalid-index)))))

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
 command-palette--validate-data-list (data data-type type-name)
 "Validate command list DATA of DATA-TYPE, removing invalid commands.
TYPE-NAME is used for logging messages.
Returns (valid-data . removed-count)."
 (let ((removed-count 0))
   (if
    (eq data-type 'ring)
    (let ((new-ring (make-ring command-palette-history-size))
          (len (ring-length data)))
      (dotimes
       (i len)
       (let* ((idx (- len 1 i))
              (item (ring-ref data idx))
              (cmd-symbol (cdr item))
              (cmd-name (car item)))
         (if
          (commandp cmd-symbol) (ring-insert new-ring item)
          (progn
           (setq removed-count (1+ removed-count))
           (logging-warning "Removed invalid %s: %s (%s)" type-name cmd-name cmd-symbol)))))
      (cons new-ring removed-count))
    (let ((valid-items nil))
      (dolist
       (item data)
       (let ((cmd-symbol (cdr item))
             (cmd-name (car item)))
         (if
          (commandp cmd-symbol) (push item valid-items)
          (progn
           (setq removed-count (1+ removed-count))
           (logging-warning "Removed invalid %s: %s (%s)" type-name cmd-name cmd-symbol)))))
      (cons (nreverse valid-items) removed-count)))))

(defun
 command-palette--validate-commands
 ()
 "Validate all commands in favorites, diagnostics, and history, removing any that no longer exist."
 (interactive)
 (let* ((fav-result
         (command-palette--validate-data-list user-command-palette-favorites 'list "favorite"))
        (diag-result
         (command-palette--validate-data-list user-command-palette-diagnostics 'list "diagnostic"))
        (hist-result
         (command-palette--validate-data-list user--command-palette-history 'ring "history item"))
        (removed-favorites (cdr fav-result))
        (removed-diagnostics (cdr diag-result))
        (removed-history (cdr hist-result)))
   (setq user-command-palette-favorites (car fav-result))
   (setq user-command-palette-diagnostics (car diag-result))
   (setq user--command-palette-history (car hist-result))
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
