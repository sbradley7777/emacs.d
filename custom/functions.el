;;; Functions.el --- Custom Functions -*- lexical-binding: t -*-
;;; Commentary:
;;      User-defined custom functions

(defvar config-load-start-time (current-time))
(message "Loading functions.el...")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Reload init.el on the Fly:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun reload-init-file ()
  (interactive)
  (let ((init-file (expand-file-name "init.el" user-emacs-directory)))
    (if (bufferp (get-file-buffer init-file))
        (save-buffer (get-buffer (file-name-nondirectory init-file))))
    (load-file init-file)
    (message "init.el reloaded successfully")))

;; Make this module available for loading with (require 'functions)
(provide 'functions)
(message "functions.el loaded (%.2fs)" (float-time (time-subtract (current-time) config-load-start-time)))
