;;; dev.el --- Development Configuration Template (Not Version Controlled) -*- lexical-binding: t -*-
;;; Commentary:
;;
;; This file serves as a template for temporary development and testing of new
;; Emacs configurations without affecting the core configuration or permanent
;; local settings.
;;
;; PURPOSE:
;; --------
;; • Testing new packages, features, or configuration changes
;; • Temporary modifications for development work
;; • Experimenting with settings before adding them to the main config
;; • Quick configuration testing without committing to permanent changes
;;
;; USAGE:
;; ------
;; Copy this file to ~/.emacs.d/dev.el and modify as needed for testing.
;; The dev.el file in your home directory will be loaded automatically if it
;; exists, after all main configuration, custom.el, and local.el have loaded.
;;
;; Unlike local.el (for permanent local settings), dev.el is intended for
;; temporary testing and development work.
;;

;;; Code:
(require 'core-logging)
(require 'core-constants)
(core-message-debug "Loading development configuration...")

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DEVELOPMENT CONFIGURATION
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Add your temporary configuration testing here

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Debug Buffer Auto-Save on Exit (for issue #38 compilation debugging)
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Automatically saves diagnostic buffers when Emacs exits to ~/.emacs.d/local/log/debug/
;; Excludes regular files, *Messages* (saved separately), and other non-debug buffers.

(defvar
 dev-buffer-exclusion-patterns
 '("^[^*]" ; Regular file buffers
   "\\*dashboard\\*"
   "\\*Messages\\*"
   "\\*scratch\\*"
   "\\*Minibuf-"
   "\\*Echo Area"
   "\\*string-pixel-width\\*"
   "\\*code-convert"
   "\\*http ")
 "Patterns for buffers to exclude from auto-save on exit.")

(defun
 dev--save-debug-buffers-on-exit ()
 "Save debug buffers to ~/.emacs.d/local/log/debug/ when Emacs exits.
Clears existing log files first, then saves current debug buffers."
 (let* ((debug-dir (expand-file-name "debug" core-log-dir))
        (case-fold-search t)
        (saved-count 0))
   ;; Create directory if needed
   (unless (file-directory-p debug-dir) (make-directory debug-dir t))
   ;; Delete existing .log files
   (dolist (old-file (directory-files debug-dir t "\\.log\\'")) (delete-file old-file))
   ;; Save current debug buffers
   (dolist
    (buf (buffer-list))
    (let ((buf-name (buffer-name buf)))
      (when
       (and
        buf-name (> (buffer-size buf) 0)
        (not (cl-some (lambda (pat) (string-match-p pat buf-name)) dev-buffer-exclusion-patterns)))
       (let* ((safe-name (string-trim (replace-regexp-in-string "[*/ ]+" "-" buf-name) "-" "-"))
              (log-file (expand-file-name (concat safe-name ".log") debug-dir)))
         (with-current-buffer buf (write-region (point-min) (point-max) log-file nil 'silent))
         (setq saved-count (1+ saved-count))))))
   (when
    (> saved-count 0)
    (core-message-success
     "Auto-saved %d debug buffer%s on exit" saved-count (if (> saved-count 1) "s" "")))))

(add-hook 'kill-emacs-hook #'dev--save-debug-buffers-on-exit)

;; Manual save function for interactive use
(defun
 dev-save-debug-buffers
 ()
 "Manually save debug buffers to ~/.emacs.d/local/log/debug/"
 (interactive)
 (dev--save-debug-buffers-on-exit))

(defun
 dev-view-debug-logs
 ()
 "Open debug log directory in dired."
 (interactive)
 (dired (expand-file-name "debug" core-log-dir)))

(core-message-success "Debug buffer auto-save enabled (saves on exit)")

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(core-message-success "Development configuration loaded successfully")
(provide 'dev)
;;; dev.el ends here
