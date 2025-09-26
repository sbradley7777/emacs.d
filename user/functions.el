;;; functions.el --- Custom Functions -*- lexical-binding: t -*-
;;; Commentary:
;;      User-defined custom functions

(require 'core-utils)
(require 'cl-lib)

(core-utils-with-load-timing
 "functions.el"

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
    (message "✅  init.el reloaded successfully")))

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
  (message "ℹ️  Buffer copied to kill ring"))

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
 (defconst
  user-buffer-filter-patterns
  '("^\\*\\(debug \\)?tramp/ssh "
    "^\\*scratch\\*$"
    "^\\*Help\\*$"
    "^\\*Completions\\*$"
    "^\\*Backtrace\\*$"
    "^\\*.*compile.*\\*$"
    "^\\*Async-native-compile-log\\*$")
  "List of regex patterns for buffers to filter out during cycling.")

 (defun
  user-buffer-should-skip-p (buffer-name) "Return t if BUFFER-NAME matches any filter pattern."
  (or
   (string-prefix-p " " buffer-name) ; Skip hidden buffers (starting with space)
   (cl-some (lambda (pattern) (string-match-p pattern buffer-name)) user-buffer-filter-patterns)))

 (defun
  user-cycle-buffer (direction)
  "Cycle through buffers in DIRECTION (:forward or :backward).
Skips buffers that match patterns in `user-buffer-filter-patterns'."
  (let ((buffer-list (if (eq direction :forward) (buffer-list) (reverse (buffer-list))))
        (current-buffer (current-buffer))
        (found-current nil)
        (target-buffer nil))
    ;; First pass: look for next buffer after current
    (cl-dolist
     (buffer buffer-list)
     (let ((buffer-name (buffer-name buffer)))
       (cond
        ;; Skip the current buffer until we find it
        ((and (not found-current) (eq buffer current-buffer))
         (setq found-current t))
        ;; Once we've found current buffer, look for next valid buffer
        ((and found-current (not (user-buffer-should-skip-p buffer-name)))
         (setq target-buffer buffer)
         (cl-return)))))
    ;; If no target found after current, wrap to beginning/end
    (unless
     target-buffer
     (cl-dolist
      (buffer buffer-list)
      (let ((buffer-name (buffer-name buffer)))
        (when
         (and (not (eq buffer current-buffer)) (not (user-buffer-should-skip-p buffer-name)))
         (setq target-buffer buffer)
         (cl-return)))))
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

 ;; Make this module available for loading with (require 'functions)
 )

(provide 'functions)
