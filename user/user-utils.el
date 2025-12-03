;;; user-utils.el --- User Utility Functions -*- lexical-binding: t -*-
;;; Commentary:
;;      User-defined utility functions for custom functionality.

;;; Code:
(require 'core-constants)
(require 'core-logging)
(require 'core-ui-utils)
(require 'core-utils)
(require 'cl-lib)

;; Declare external variables to suppress byte-compiler warnings
(defvar corfu-mode) ; From corfu.el
(defvar corfu--visible) ; From corfu.el (internal variable)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 user-reload-init-file ()
 "Reload init.el configuration file.
Saves init.el buffer if it's currently open before reloading."
 (interactive)
 (let ((init-file (expand-file-name "init.el" user-emacs-directory)))
   (if
    (bufferp (get-file-buffer init-file))
    (save-buffer (get-buffer (file-name-nondirectory init-file))))
   (load-file init-file)
   (logging-success "init.el reloaded successfully")))

(defun
 user-copy-whole-buffer
 ()
 "Copy the entire buffer to the kill ring.
This is equivalent to doing \\[mark-whole-buffer] followed by `M-w'."
 (interactive)
 (kill-ring-save (point-min) (point-max))
 (logging-info "Buffer copied to kill ring"))

(defun
 user-smart-page-up ()
 "Page up with smart boundary handling.
When reaching the beginning of buffer, move point to beginning."
 (interactive)
 (condition-case nil
     (scroll-down)
   (beginning-of-buffer
    (goto-char (point-min)))))

(defun
 user-smart-page-down ()
 "Page down with smart boundary handling.
When reaching the end of buffer, move point to end."
 (interactive)
 (condition-case nil
     (scroll-up)
   (end-of-buffer
    (goto-char (point-max)))))

(defun
 user-smart-tab ()
 "Context-aware TAB key behavior for completion and indentation.

In minibuffer: Performs minibuffer completion.
With corfu-mode active: Triggers `completion-at-point', falling back to indentation.
Otherwise: Performs standard indentation only.

This provides a unified TAB key experience across different editing contexts."
 (interactive)
 (if
  (minibufferp)
  (minibuffer-complete)
  (if corfu-mode (or (completion-at-point) (indent-for-tab-command)) (indent-for-tab-command))))

(defun
 user-completion-or-indent
 ()
 "Trigger completion when Corfu is inactive, otherwise indent.

This function checks if Corfu completion is currently visible:
- If Corfu is enabled but not showing completions: triggers `completion-at-point'
- Otherwise: performs standard indentation

Useful for binding to keys where you want completion priority over indentation."
 (interactive)
 (if (and corfu-mode (not corfu--visible)) (completion-at-point) (indent-for-tab-command)))

(defun
 user-buffer-should-skip-p (buffer)
 "Return t if BUFFER should be skipped during cycling.

Buffers INCLUDED in cycling:
  - *Messages* buffer (for viewing Emacs messages)
  - File-visiting buffers (any buffer editing a file)

Buffers EXCLUDED from cycling:
  - *scratch* and other special buffers (except *Messages*)
  - Dired buffers (directory listings)
  - Hidden buffers (names starting with space)
  - Temporary/internal buffers (*Completions*, *Backtrace*, etc.)"
 (let ((name (buffer-name buffer)))
   (not
    (or
     ;; Allow *Messages* buffer
     (string= name "*Messages*")
     ;; Allow buffers visiting files (not dired, not special buffers)
     (buffer-file-name buffer)))))

(defun
 user-cycle-buffer (direction)
 "Cycle through buffers in DIRECTION (:forward or :backward).
Skips buffers that should not be included in cycling.
Works even when called from an excluded buffer (e.g., dashboard, *scratch*)."
 (let* ( ;; Get buffers in stable order (sorted by name for consistency)
        (all-buffers (sort (buffer-list) (lambda (a b) (string< (buffer-name a) (buffer-name b)))))
        ;; Filter valid buffers first, maintaining sorted order
        (valid-buffers
         (seq-filter (lambda (buf) (not (user-buffer-should-skip-p buf))) all-buffers))
        (current-buffer (current-buffer))
        (current-index (cl-position current-buffer valid-buffers))
        (num-buffers (length valid-buffers))
        (target-buffer nil))
   (when
    (> num-buffers 0)
    ;; If current buffer is excluded (current-index is nil), start from first or last
    (if
     (null current-index)
     (setq
      target-buffer
      (if (eq direction :forward) (nth 0 valid-buffers) (nth (1- num-buffers) valid-buffers)))
     ;; Otherwise cycle normally
     (when
      (> num-buffers 1)
      (let ((next-index
             (if
              (eq direction :forward)
              (mod (1+ current-index) num-buffers)
              (mod (1- current-index) num-buffers))))
        (setq target-buffer (nth next-index valid-buffers))))))
   ;; Switch to target buffer if found
   (when target-buffer (switch-to-buffer target-buffer))))

(defun
 user-next-buffer ()
 "Cycle forward to the next buffer in the buffer list.

Skips internal buffers, dired buffers, and other filtered buffers.
Only cycles through file-visiting buffers and the *Messages* buffer.
If called from an excluded buffer, jumps to the first valid buffer."
 (interactive) (user-cycle-buffer :forward))

(defun
 user-previous-buffer ()
 "Cycle backward to the previous buffer in the buffer list.

Skips internal buffers, dired buffers, and other filtered buffers.
Only cycles through file-visiting buffers and the *Messages* buffer.
If called from an excluded buffer, jumps to the last valid buffer."
 (interactive) (user-cycle-buffer :backward))

(defun
 user-git-commit-format ()
 "Remove 2 leading spaces from the subject line and body of a git commit message.

This function is used to format Claude-generated git commit messages when editing
a commit message.  Claude often generates commit messages with 2-space indentation,
and this function removes that leading indentation to produce properly formatted
commit messages.

Only formats the subject line and body (including section headers like \\='Changes:\\=').
Stops processing and preserves original formatting when encountering known git
trailers or git comments (lines starting with \\='#\\=').

Known trailers include: Signed-off-by, Co-authored-by, Reviewed-by, Acked-by,
Tested-by, Reported-by, Suggested-by, Helped-by, Cc, Fixes, Closes, Resolves,
See-also, Reference."
 (interactive)
 (save-excursion
  ;; Find the end of the formattable region (subject + body only, before trailers or git comments)
  (goto-char (point-min))
  (let
      ((format-end
        (if
         (re-search-forward
          "^\\(Signed-off-by:\\|Co-authored-by:\\|Reviewed-by:\\|Acked-by:\\|Tested-by:\\|Reported-by:\\|Suggested-by:\\|Helped-by:\\|Cc:\\|Fixes:\\|Closes:\\|Resolves:\\|See-also:\\|Reference:\\|#\\)"
          nil
          t)
         (progn (beginning-of-line) (point)) (point-max))))
    (save-restriction
     (narrow-to-region (point-min) format-end)
     ;; Remove 2 leading spaces from all lines in subject and body (including section headers)
     (goto-char (point-min))
     (while (re-search-forward "^  " nil t) (replace-match "") (beginning-of-line 2))))))

(defun
 user-close-exclusive-side-windows ()
 "Close all exclusive side windows (F1: Flymake, F5: Imenu-list, F9: Command Palette).
This ensures only one of these windows is open at a time."
 ;; Close Flymake diagnostics window (F1)
 (core-close-window-by-buffer-name "*Flymake diagnostics")

 ;; Close Imenu-list window (F5)
 (core-close-window-by-buffer-name "*Ilist*" t)

 ;; Close Command Palette window (F9)
 (when
  (boundp 'user-command-palette-window)
  (when
   (and user-command-palette-window (window-live-p user-command-palette-window))
   (delete-window user-command-palette-window)
   (setq user-command-palette-window nil))))

(defun
 user-imenu-list-smart-toggle ()
 "Toggle Imenu-list with mutual exclusion from other side windows.
This wrapper ensures that opening Imenu-list closes other exclusive side windows (F1, F9)."
 (interactive)
 ;; Find if imenu-list window is currently open
 (let ((imenu-window (core-find-window-by-buffer-name "*Ilist*" t)))
   ;; If not open, close other exclusive windows first
   (unless imenu-window (user-close-exclusive-side-windows))
   ;; Call the original toggle function
   (when (fboundp 'imenu-list-smart-toggle) (imenu-list-smart-toggle))))
(provide 'user-utils)
;;; user-utils.el ends here
