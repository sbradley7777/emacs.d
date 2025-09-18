;;; functions.el --- Custom Functions -*- lexical-binding: t -*-
;;; Commentary:
;;      User-defined custom functions

(require 'core-utils)

(core-utils-with-load-timing
 "functions.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Reload init.el on the Fly:
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  user-reload-init-file () (interactive)
  (let ((init-file (expand-file-name "init.el" user-emacs-directory)))
    (if
     (bufferp (get-file-buffer init-file))
     (save-buffer (get-buffer (file-name-nondirectory init-file))))
    (load-file init-file)
    (message "✅  init.el reloaded successfully")))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Copy Entire Buffer to Kill Ring:
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  user-copy-whole-buffer
  ()
  "Copy the entire buffer to the kill ring.
This is equivalent to doing M-x mark-whole-buffer followed by M-w."
  (interactive)
  (kill-ring-save (point-min) (point-max))
  (message "ℹ️  Buffer copied to kill ring"))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Smart Page Navigation Functions:
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Smart TAB Completion Functions:
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

 ;; Make this module available for loading with (require 'functions)
 (provide 'functions))
