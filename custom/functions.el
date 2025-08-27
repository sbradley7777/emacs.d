;;; functions.el --- Custom Functions
;;; Commentary:
;;      User-defined custom functions

(message "Loading functions.el...")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Accept y or n Instead of yes or no:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun yes-or-no-p (arg)
  "An alias for y-or-n-p, because I hate having to type 'yes' or 'no'."
  (y-or-n-p arg))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Reload init.el on the Fly:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun reload-init-file()
  (interactive)
  (let ((init-file (expand-file-name "init.el" user-emacs-directory)))
    (if (bufferp (get-file-buffer init-file))
        (save-buffer (get-buffer (file-name-nondirectory init-file))))
    (load-file init-file)
    (message "init.el reloaded successfully")))

(provide 'functions)
(message "functions.el loaded successfully.")
