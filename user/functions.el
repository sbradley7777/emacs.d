;;; functions.el --- Custom Functions -*- lexical-binding: t -*-
;;; Commentary:
;;      User-defined custom functions

(require 'utils)

(with-load-timing
 "functions.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Reload init.el on the Fly:
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  reload-init-file () (interactive)
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
  copy-whole-buffer
  ()
  "Copy the entire buffer to the kill ring.
This is equivalent to doing M-x mark-whole-buffer followed by M-w."
  (interactive)
  (save-excursion (mark-whole-buffer) (kill-ring-save (point-min) (point-max)))
  (message "ℹ️  Buffer copied to kill ring"))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Smart Page Navigation Functions:
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  smart-page-up ()
  "Page up with smart boundary handling.
When reaching the beginning of buffer, move point to beginning."
  (interactive)
  (condition-case nil
      (scroll-down)
    (beginning-of-buffer
     (goto-char (point-min)))))

 (defun
  smart-page-down ()
  "Page down with smart boundary handling.
When reaching the end of buffer, move point to end."
  (interactive)
  (condition-case nil
      (scroll-up)
    (end-of-buffer
     (goto-char (point-max)))))

 ;; Make this module available for loading with (require 'functions)
 (provide 'functions))
