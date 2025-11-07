;;; command-palette.el --- Clickable Side Window Command Launcher -*- lexical-binding: t -*-
;;; Commentary:
;;
;; Provides a persistent side-window command palette with:
;; - Clickable buttons for frequently used commands
;; - Automatic tracking of M-x command history
;; - Customizable favorites list
;; - Persistent storage of history and favorites
;;
;; Usage: Press C-c p to toggle the command palette
(require 'core-constants)
(require 'core-utils)
(require 'core-logging)
(require 'core-user-interaction-utils)
(require 'package-ui)
(require 'package-maintenance)
(core-utils-with-load-timing
 "command-palette.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Constants
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defconst
  command-palette-data-dir
  (expand-file-name "command_palette/" emacs-local-dir)
  "Directory for command palette persistent data.")
 (defconst
  command-palette-history-file
  (expand-file-name "command-palette-history.el" command-palette-data-dir)
  "File storing command palette history.")
 (defconst
  command-palette-favorites-file
  (expand-file-name "command-palette-favorites.el" command-palette-data-dir)
  "File storing command palette favorites.")
 (defconst command-palette-buffer-name "*Command Palette*" "Name of the command palette buffer.")
 (defconst command-palette-history-size 20 "Maximum number of commands to store in history.")
 (defconst
  command-palette-default-favorites
  '(("User Git Commit Format" . user-git-commit-format)
    ("User Copy Whole Buffer" . user-copy-whole-buffer)
    ("Menu Bar Open" . menu-bar-open)
    ("Diagnostics Show All" . diagnostics-show-all)
    ("Diagnostics Show Forge Hosts" . forge-utils-diagnostics-show-hosts)
    ("Show Installed Packages" . show-installed-packages)
    ("Search Packages" . search-packages)
    ("Show Package Upgrades" . show-package-upgrades)
    ("List Themes" . list-themes)
    ("Pyvenv Activate" . pyvenv-activate)
    ("Pyvenv Deactivate" . pyvenv-deactivate)
    ("Pyvenv Workon" . pyvenv-workon)
    ("Run Python" . run-python)
    ("Shell" . shell)
    ("Treesit Install Language Grammar" . treesit-install-language-grammar)
    ("Elisp Autofmt Buffer" . elisp-autofmt-buffer)
    ("Vertico Next" . vertico-next)
    ("Project List Buffers" . project-list-buffers)
    ("Magit Status" . magit-status)
    ("Git Sync Repository" . git-sync-repository)
    ("List Git Issues" . forge-issues-list)
    ("Generate Forge Authinfo Entries" . forge-authinfo-generate-entries))
  "Default list of favorite commands. Format: ((\"Display Name\" . command-symbol) ...).")

 (defconst
  command-palette-excluded-commands
  '(command-palette-toggle
    command-palette-add-favorite
    command-palette-remove-favorite
    command-palette-clear-history
    keyboard-quit
    keyboard-escape-quit
    abort-recursive-edit
    exit-minibuffer
    minibuffer-complete
    minibuffer-complete-and-exit
    completion-at-point
    minibuffer-completion-help
    self-insert-command
    delete-backward-char
    y-or-n-p-insert-other
    undefined)
  "Commands to exclude from M-x history tracking.")

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Variables
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defvar command-palette-window nil "Window displaying the command palette.")
 (defvar
  command-palette-history
  (make-ring command-palette-history-size)
  "Ring buffer storing recently executed commands from palette.")
 (defvar
  command-palette-favorites
  nil
  "List of favorite commands displayed in the palette. Loaded from file or defaults.")
 (defvar
  command-palette-previous-window nil "Window that was active before opening the command palette.")
 (defvar
  command-palette-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "q") 'command-palette-toggle)
    (define-key map (kbd "a") 'command-palette-add-favorite)
    (define-key map (kbd "r") 'command-palette-remove-favorite)
    (define-key map (kbd "v") 'command-palette-validate-commands)
    map)
  "Keymap for command palette buffer.")

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Directory Management
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  command-palette--ensure-data-directory
  ()
  "Ensure the command palette data directory exists, creating it if necessary."
  (core-utils-ensure-directory command-palette-data-dir))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Persistence Functions - History
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  command-palette--save-history
  ()
  "Save command history to persistent storage."
  (command-palette--ensure-data-directory)
  (condition-case err
      (with-temp-file
       command-palette-history-file
       (insert
        ";;; command-palette-history.el --- Command Palette History -*- lexical-binding: t -*-\n")
       (insert ";;;\n")
       (insert ";;; This file stores the command palette execution history.\n")
       (insert ";;; Generated automatically - do not edit manually.\n")
       (insert ";;;\n\n")
       (insert "(setq command-palette-saved-history\n")
       (insert "  '(")
       (let ((first t))
         (dotimes
          (i (ring-length command-palette-history))
          (let ((item (ring-ref command-palette-history i)))
            (unless first (insert "\n    "))
            (setq first nil)
            (insert (format "%S" item)))))
       (insert "))\n\n")
       (insert ";;; command-palette-history.el ends here\n"))
    (error
     (core-message-error
      "Failed to save command palette history: %s" (error-message-string err)))))

 (defun
  command-palette--load-history (&optional silent)
  "Load command history from persistent storage.
If SILENT is non-nil, suppress success messages. Returns t if successful, nil otherwise."
  (when
   (file-exists-p command-palette-history-file)
   (condition-case err
       (progn
        (load command-palette-history-file)
        (when
         (boundp 'command-palette-saved-history)
         (setq command-palette-history (make-ring command-palette-history-size))
         (dolist
          (item (reverse command-palette-saved-history))
          (ring-insert command-palette-history item))
         (unless
          silent
          (core-message-success
           "Loaded %d command(s) from history" (length command-palette-saved-history)))
         t))
     (error
      (core-message-warning
       "Failed to load command palette history: %s" (error-message-string err))
      nil))))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Persistence Functions - Favorites
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  command-palette--save-favorites
  ()
  "Save favorites list to persistent storage."
  (command-palette--ensure-data-directory)
  (condition-case err
      (with-temp-file
       command-palette-favorites-file
       (insert
        ";;; command-palette-favorites.el --- Command Palette Favorites -*- lexical-binding: t -*-\n")
       (insert ";;;\n")
       (insert ";;; This file stores the command palette favorites list.\n")
       (insert ";;; Generated automatically - do not edit manually.\n")
       (insert ";;;\n\n")
       (insert "(setq command-palette-saved-favorites\n")
       (insert "  '(")
       (let ((first t))
         (dolist
          (item command-palette-favorites)
          (unless first (insert "\n    "))
          (setq first nil)
          (insert (format "%S" item))))
       (insert "))\n\n")
       (insert ";;; command-palette-favorites.el ends here\n"))
    (error
     (core-message-error
      "Failed to save command palette favorites: %s" (error-message-string err)))))

 (defun
  command-palette--load-favorites (&optional silent)
  "Load favorites from persistent storage.
If SILENT is non-nil, suppress success messages. Returns t if successful, nil otherwise."
  (if
   (file-exists-p command-palette-favorites-file)
   (condition-case err
       (progn
        (load command-palette-favorites-file)
        (when
         (boundp 'command-palette-saved-favorites)
         (setq command-palette-favorites command-palette-saved-favorites)
         (unless
          silent
          (core-message-success
           "Loaded %d favorite command(s)" (length command-palette-favorites)))
         t))
     (error
      (core-message-warning
       "Failed to load command palette favorites: %s" (error-message-string err))
      (setq command-palette-favorites command-palette-default-favorites)
      nil))
   (progn
    (setq command-palette-favorites command-palette-default-favorites)
    (unless silent (core-message-info "Using default command palette favorites"))
    nil)))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Helper Functions
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  command-palette--format-command-name (cmd-symbol)
  "Convert CMD-SYMBOL to human-readable format.
Example: 'find-file' becomes 'Find File'."
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
Removes any existing occurrences before adding to ensure no duplicates. Returns t if added, nil if excluded."
  (when
   (and
    (symbolp cmd-symbol)
    (commandp cmd-symbol)
    (not (memq cmd-symbol command-palette-excluded-commands))
    ;; Don't add to history if it's already in favorites
    (not
     (assoc
      cmd-symbol (mapcar (lambda (item) (cons (cdr item) (car item))) command-palette-favorites))))
   ;; Remove all existing occurrences of this command from the ring
   (let ((new-ring (make-ring command-palette-history-size))
         (cmd-name (command-palette--format-command-name cmd-symbol))
         (len (ring-length command-palette-history)))
     ;; Iterate from oldest to newest to preserve order when inserting
     (dotimes
      (i len)
      (let* ((idx (- len 1 i)) ; Start from the end (oldest)
             (item (ring-ref command-palette-history idx)))
        (unless (eq (cdr item) cmd-symbol) (ring-insert new-ring item))))
     ;; Replace old ring with new deduplicated ring
     (setq command-palette-history new-ring)
     ;; Insert the command at the front (most recent position)
     (ring-insert command-palette-history (cons cmd-name cmd-symbol))
     (command-palette--save-history)
     (command-palette--refresh-buffer)
     t)))

 (defun
  command-palette--execute-command (cmd-symbol cmd-name)
  "Execute command CMD-SYMBOL and add CMD-NAME to history.
Switches to the previous window before executing the command, then closes the palette."
  ;; Use add-to-history for deduplication
  (command-palette--add-to-history cmd-symbol)
  ;; Close the command palette window
  (when
   (and command-palette-window (window-live-p command-palette-window))
   (delete-window command-palette-window)
   (setq command-palette-window nil))
  ;; Find the target window (previous window or another suitable window)
  (let ((target-window
         (or
          (and
           command-palette-previous-window
           (window-live-p command-palette-previous-window)
           command-palette-previous-window)
          ;; Find first non-palette window
          (cl-find-if
           (lambda
            (win) (not (string= (buffer-name (window-buffer win)) command-palette-buffer-name)))
           (window-list)))))
    (when target-window (select-window target-window))
    (call-interactively cmd-symbol)))
 (defun
  command-palette--make-button (label action face &optional keybinding)
  "Create a clickable button with LABEL that executes ACTION. Use FACE for styling.
If KEYBINDING is provided, display it in parentheses with a red color."
  (let ((start (point)))
    (insert "  " label)
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
     (insert (propertize (format "(%s)" keybinding) 'face '(:foreground "#e74c3c"))))
    (insert "\n")))
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
     ;; Add 2 for a small margin
     (+ max-width 2))))
 (defun
  command-palette--refresh-buffer () "Refresh the command palette buffer contents."
  (let ((buffer (get-buffer command-palette-buffer-name)))
    (when
     buffer
     (with-current-buffer
      buffer
      (let ((inhibit-read-only t)
            (line (line-number-at-pos)))
        (erase-buffer)
        (command-palette--render-content)
        (goto-char (point-min))
        (forward-line (1- line)))))))
 (defun
  command-palette--render-content () "Render the command palette buffer content."

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Header
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  (insert (propertize "    ━━━ COMMAND PALETTE ━━━\n\n" 'face '(:weight bold :foreground "cyan")))

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Favorites Section
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  (insert (propertize " ⭐ Favorite Commands:\n" 'face '(:weight bold :foreground "green")))
  (let ((index 1))
    (dolist
     (item command-palette-favorites)
     (let* ((name (car item))
            (cmd (cdr item))
            (keybinding (command-palette--get-keybinding cmd)))
       (command-palette--make-button
        (format "  %2d. %s" index name)
        `(lambda (_) (command-palette--execute-command ',cmd ,name))
        '(:foreground "lightgreen")
        keybinding)
       (setq index (1+ index)))))
  (insert "\n")

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Recent Commands Section
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  (when
   (> (ring-length command-palette-history) 0)
   (insert (propertize " ↻  Recent Commands:\n" 'face '(:weight bold :foreground "yellow")))
   (dotimes
    (i (ring-length command-palette-history))
    (let* ((item (ring-ref command-palette-history i))
           (name (car item))
           (cmd (cdr item))
           (index (1+ i))
           (keybinding (command-palette--get-keybinding cmd)))
      (command-palette--make-button
       (format "  %2d. %s" index name)
       `(lambda (_) (command-palette--execute-command ',cmd ,name))
       '(:foreground "orange")
       keybinding)))
   (insert "\n"))

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Actions Section
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  (insert (propertize " ⚙️  Actions:\n" 'face '(:weight bold :foreground "magenta")))
  (command-palette--make-button
   "  📌 Promote Recent to Favorite"
   (lambda (_) (call-interactively 'command-palette-add-favorite))
   '(:foreground "cyan"))
  (command-palette--make-button
   "  🗑️  Remove Favorite by Index"
   (lambda (_) (call-interactively 'command-palette-remove-favorite))
   '(:foreground "red"))
  (command-palette--make-button
   "  🔄 Clear History" (lambda (_) (command-palette-clear-history)) '(:foreground "yellow"))
  (command-palette--make-button
   "  🔍 Validate Commands"
   (lambda (_) (command-palette-validate-commands))
   '(:foreground "lightblue"))
  (command-palette--make-button
   "  ❌ Close Palette" (lambda (_) (command-palette-toggle)) '(:foreground "gray"))

  (insert "\n") (insert (propertize " Keys:\n" 'face '(:foreground "gray" :slant italic)))
  (insert
   (propertize
    "    • 'a' - promote recent to favorite\n" 'face '(:foreground "gray" :slant italic)))
  (insert
   (propertize "    • 'r' - remove favorite by index\n" 'face '(:foreground "gray" :slant italic)))
  (insert
   (propertize
    "    • 'v' - validate and remove nonexistent commands\n"
    'face
    '(:foreground "gray" :slant italic)))
  (insert (propertize "    • 'q' - quit" 'face '(:foreground "gray" :slant italic))))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Interactive Commands
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  command-palette-add-favorite ()
  "Promote a recent command from history to the favorites list.

Prompts for an index number from the recent commands list, then moves that
command to the favorites section and removes it from history. The command is
persisted to disk immediately. Useful for pinning frequently-used commands."
  (interactive)
  (if
   (= (ring-length command-palette-history) 0)
   (core-message-warning "No recent commands to promote. Execute commands via M-x first.")
   (let* ((max-index (ring-length command-palette-history))
          (index
           (core-user-read-number
            (format "Promote recent command to favorites (1 - %d): " max-index) 1 max-index)))
     (if
      index
      (let* ((item (ring-ref command-palette-history (1- index)))
             (cmd-name (car item))
             (cmd-symbol (cdr item)))
        ;; Add to favorites
        (add-to-list 'command-palette-favorites item t)
        (command-palette--save-favorites)
        ;; Remove from history by rebuilding the ring without this item
        (let ((new-ring (make-ring command-palette-history-size)))
          (dotimes
           (i (ring-length command-palette-history))
           (let ((hist-item (ring-ref command-palette-history i)))
             (unless
              (eq (cdr hist-item) cmd-symbol) (ring-insert-at-beginning new-ring hist-item))))
          (setq command-palette-history new-ring))
        (command-palette--save-history)
        (command-palette--refresh-buffer)
        (core-message-success "Promoted #%d '%s' to favorites" index cmd-name))
      (core-message-warning "Invalid index or cancelled")))))
 (defun
  command-palette-remove-favorite ()
  "Remove a command from the favorites list by index number.

Prompts for an index number from the favorites list, then permanently removes
that command from favorites. The change is persisted to disk immediately.
Does not affect the command's availability in M-x."
  (interactive)
  (if
   (= (length command-palette-favorites) 0) (core-message-warning "No favorites to remove")
   (let* ((max-index (length command-palette-favorites))
          (index
           (core-user-read-number
            (format "Remove favorite by index (1 - %d): " max-index) 1 max-index)))
     (if
      index
      (let* ((item-to-remove (nth (1- index) command-palette-favorites))
             (cmd-name (car item-to-remove)))
        (setq command-palette-favorites (cl-remove item-to-remove command-palette-favorites))
        (command-palette--save-favorites)
        (command-palette--refresh-buffer)
        (core-message-success "Removed favorite #%d: '%s'" index cmd-name))
      (core-message-warning "Invalid index or cancelled")))))
 (defun
  command-palette-clear-history
  ()
  "Clear all recent commands from the command palette history.

Removes all entries from the recent commands section while preserving favorites.
The cleared history is persisted to disk immediately. Use this to reset your
recent commands list while keeping your favorites intact."
  (interactive)
  (setq command-palette-history (make-ring command-palette-history-size))
  (command-palette--save-history)
  (command-palette--refresh-buffer)
  (core-message-success "Command palette history cleared"))
 (defun
  command-palette-validate-commands
  ()
  "Validate all commands in favorites and history, removing any that no longer exist."
  (interactive)
  (let ((removed-favorites 0)
        (removed-history 0))
    ;; Validate favorites
    (let ((valid-favorites nil))
      (dolist
       (item command-palette-favorites)
       (let ((cmd-symbol (cdr item))
             (cmd-name (car item)))
         (if
          (and (fboundp cmd-symbol) (commandp cmd-symbol)) (push item valid-favorites)
          (progn
           (setq removed-favorites (1+ removed-favorites))
           (core-message-warning "Removed invalid favorite: %s (%s)" cmd-name cmd-symbol)))))
      (setq command-palette-favorites (nreverse valid-favorites)))
    ;; Validate history
    (let ((new-ring (make-ring command-palette-history-size))
          (len (ring-length command-palette-history)))
      (dotimes
       (i len)
       (let* ((idx (- len 1 i))
              (item (ring-ref command-palette-history idx))
              (cmd-symbol (cdr item))
              (cmd-name (car item)))
         (if
          (and (fboundp cmd-symbol) (commandp cmd-symbol)) (ring-insert new-ring item)
          (progn
           (setq removed-history (1+ removed-history))
           (core-message-warning "Removed invalid history item: %s (%s)" cmd-name cmd-symbol)))))
      (setq command-palette-history new-ring))
    ;; Save changes
    (when (> removed-favorites 0) (command-palette--save-favorites))
    (when (> removed-history 0) (command-palette--save-history))
    ;; Refresh buffer
    (command-palette--refresh-buffer)
    ;; Report results
    (if
     (and (= removed-favorites 0) (= removed-history 0))
     (core-message-success "All commands are valid")
     (core-message-success
      "Validation complete: removed %d favorite(s) and %d history item(s)"
      removed-favorites
      removed-history))))
 (defun
  command-palette-toggle ()
  "Toggle the command palette side window display.

Opens the command palette in a side window showing favorite and recent commands.
If already open, closes it. When opening, automatically closes other exclusive
side windows (Flymake diagnostics, Imenu-list) and reloads the latest command
data from disk to ensure freshness."
  (interactive)
  (if
   (and command-palette-window (window-live-p command-palette-window))
   (progn
    (delete-window command-palette-window)
    (setq command-palette-window nil)
    (core-message-info "Command palette closed"))
   ;; Close other exclusive side windows before opening
   (when (fboundp 'user-close-exclusive-side-windows) (user-close-exclusive-side-windows))
   ;; Store current window before opening palette
   (setq command-palette-previous-window (selected-window))
   ;; Reload history and favorites from disk to ensure freshness (silently)
   (command-palette--load-favorites t) (command-palette--load-history t)
   (let* ((buffer (get-buffer-create command-palette-buffer-name))
          (window-width nil))
     (with-current-buffer
      buffer
      (let ((inhibit-read-only t))
        (erase-buffer)
        (command-palette--render-content)
        ;; Calculate width based on content
        (setq window-width (command-palette--calculate-window-width)))
      (setq buffer-read-only t)
      (setq-local cursor-type nil)
      (use-local-map command-palette-mode-map)
      (hl-line-mode 1))
     (setq
      command-palette-window
      (display-buffer-in-side-window
       buffer `((side . right) (window-width . ,window-width) (slot . 0))))
     (select-window command-palette-window)
     ;; Move cursor to first favorite item (skip header and section title)
     (goto-char (point-min))
     (forward-line 3)
     (core-message-success "Command palette opened"))))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; M-x Command Tracking
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defvar command-palette--mx-flag nil "Flag set when M-x is invoked.")
 (defun
  command-palette--track-command () "Track commands executed via M-x using post-command-hook."
  ;; Set flag when M-x is invoked
  (when
   (memq this-command '(execute-extended-command execute-extended-command-for-buffer))
   (setq command-palette--mx-flag t))
  ;; Track the next real command after M-x
  (when
   (and
    command-palette--mx-flag this-command (commandp this-command)
    (not
     (memq this-command '(execute-extended-command execute-extended-command-for-buffer)))
    (not (memq this-command command-palette-excluded-commands)))
   (command-palette--add-to-history this-command) (setq command-palette--mx-flag nil)))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Initialization
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Load saved data
 (command-palette--load-favorites)
 (command-palette--load-history)

 ;; Enable M-x command tracking via post-command-hook
 (add-hook 'post-command-hook #'command-palette--track-command)

 ;; Save on exit
 (add-hook 'kill-emacs-hook #'command-palette--save-history)
 (add-hook 'kill-emacs-hook #'command-palette--save-favorites)

 (core-message-success "Command palette loaded!"))
(provide 'command-palette)
;;; command-palette.el ends here
