;;; user-functions.el --- Custom Functions -*- lexical-binding: t -*-
;;; Commentary:
;;      User-defined custom functions

(require 'cl-lib)

(core-utils-with-load-timing
 "user-functions.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Reload init.el on the Fly:
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  user-reload-init-file () (interactive)
  (let ((init-file (expand-file-name "init.el" user-emacs-directory)))
    (if
     (bufferp (get-file-buffer init-file))
     (save-buffer (get-buffer (file-name-nondirectory init-file))))
    (load-file init-file)
    (core-message-success "init.el reloaded successfully")))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Copy Entire Buffer to Kill Ring:
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  user-copy-whole-buffer
  ()
  "Copy the entire buffer to the kill ring.
This is equivalent to doing M-x mark-whole-buffer followed by M-w."
  (interactive)
  (kill-ring-save (point-min) (point-max))
  (core-message-info "Buffer copied to kill ring"))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Smart Page Navigation Functions:
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Smart TAB Completion Functions:
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  user-smart-tab () "Smart TAB: complete if possible, otherwise indent." (interactive)
  (if
   (minibufferp) (minibuffer-complete)
   (if corfu-mode (or (completion-at-point) (indent-for-tab-command)) (indent-for-tab-command))))

 (defun
  user-completion-or-indent
  ()
  "Trigger completion or indent, depending on context."
  (interactive)
  (if (and corfu-mode (not corfu--visible)) (completion-at-point) (indent-for-tab-command)))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Custom Buffer Cycling Functions:
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
         (all-buffers
          (sort (buffer-list) (lambda (a b) (string< (buffer-name a) (buffer-name b)))))
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
  user-next-buffer
  ()
  "Switch to the next buffer, skipping filtered buffers."
  (interactive)
  (user-cycle-buffer :forward))

 (defun
  user-previous-buffer
  ()
  "Switch to the previous buffer, skipping filtered buffers."
  (interactive)
  (user-cycle-buffer :backward))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Side Window Mutual Exclusion:
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  user-close-exclusive-side-windows ()
  "Close all exclusive side windows (F1: Flymake, F5: Imenu-list, F9: Command Palette).
This ensures only one of these windows is open at a time."
  ;; Close Flymake diagnostics window (F1)
  (let ((flymake-window
         (cl-find-if
          (lambda
           (window) (string-prefix-p "*Flymake diagnostics" (buffer-name (window-buffer window))))
          (window-list))))
    (when flymake-window (quit-window nil flymake-window)))

  ;; Close Imenu-list window (F5)
  (let ((imenu-window
         (cl-find-if
          (lambda
           (window) (string= "*Ilist*" (buffer-name (window-buffer window))))
          (window-list))))
    (when imenu-window (quit-window nil imenu-window)))

  ;; Close Command Palette window (F9)
  (when
   (boundp 'command-palette-window)
   (when
    (and command-palette-window (window-live-p command-palette-window))
    (delete-window command-palette-window)
    (setq command-palette-window nil))))

 (defun
  user-imenu-list-smart-toggle ()
  "Toggle Imenu-list with mutual exclusion from other side windows.
This wrapper ensures that opening Imenu-list closes other exclusive side windows (F1, F9)."
  (interactive)
  ;; Find if imenu-list window is currently open
  (let ((imenu-window
         (cl-find-if
          (lambda
           (window) (string= "*Ilist*" (buffer-name (window-buffer window))))
          (window-list))))
    ;; If not open, close other exclusive windows first
    (unless imenu-window (user-close-exclusive-side-windows))
    ;; Call the original toggle function
    (when (fboundp 'imenu-list-smart-toggle) (imenu-list-smart-toggle)))))

(provide 'user-functions)
