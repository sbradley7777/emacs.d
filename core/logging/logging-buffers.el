;;; logging-buffers.el --- Buffer Logging (Messages and Debug) -*- lexical-binding: t -*-
;;; Commentary:
;; Buffer logging implementations for Messages buffer and debug buffers.
;; Uses shared rotation utilities from logging-utils.el.
;;
;; Messages Buffer Logging:
;;   - Automatically saves *Messages* buffer on Emacs exit
;;   - Saved to ~/.emacs.d/local/log/messages.log with rotation
;;
;; Debug Buffer Auto-Save:
;;   - Automatically saves diagnostic/warning/compile buffers on Emacs exit
;;   - Saved to ~/.emacs.d/local/log/debug/ with rotation
;;   - Disabled by default - users enable via local.el:
;;     (add-hook 'kill-emacs-hook #'logging--save-debug-buffers-on-exit)
;;
;; Manual command:
;;   M-x logging-save-debug-buffers - Save debug buffers immediately

;;; Code:
(require 'core-constants)
(require 'core-logging)
(require 'logging-utils)
(require 'subr-x)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar
 logging-debug-exclusion-patterns
 '("^[^*]" ; Regular file buffers
   "\\*dashboard\\*"
   "\\*Messages\\*"
   "\\*scratch\\*"
   "\\*Minibuf-"
   "\\*Echo Area"
   "\\*string-pixel-width\\*"
   "\\*code-convert"
   "\\*http ")
 "Patterns for buffers to exclude from debug auto-save.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions - Messages Buffer Logging
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 logging--save-messages-buffer () "Save Messages buffer to log file with rotation and timestamp."
 (let ((log-file
        (core-save-buffer-to-log
         "*Messages*" core-messages-log-file core-log-dir
         ;; Footer function: add session end timestamp
         (lambda () (insert (format "\n;; Session ended: %s\n" (current-time-string)))))))
   (when log-file (logging-success "Messages log saved to %s" (abbreviate-file-name log-file)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions - Debug Buffer Logging
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 logging--should-save-debug-buffer-p (buffer-name)
 "Return non-nil if BUFFER-NAME should be saved as a debug buffer.
Checks buffer name against exclusion patterns."
 (and
  buffer-name
  (not
   (cl-some
    (lambda (pattern) (string-match-p pattern buffer-name)) logging-debug-exclusion-patterns))))

(defun
 logging--sanitize-buffer-name (buffer-name)
 "Convert BUFFER-NAME to safe filename.
Example: \\='*EGLOT (elisp-mode) stderr*\\=' → \\='EGLOT-elisp-mode-stderr\\='"
 (string-trim (replace-regexp-in-string "[*/ ():]+" "-" buffer-name) "-" "-"))

(defun
 logging--save-debug-buffers-on-exit ()
 "Save debug buffers to ~/.emacs.d/local/log/debug/ with rotation.
Each debug buffer is saved with rotation history (e.g., Warnings.log → Warnings.log.1).
Only saves buffers with content that match debug patterns.
Only creates the debug directory if there are buffers to save."
 (let ((debug-dir (expand-file-name "debug" core-log-dir))
       (case-fold-search t)
       (buffers-to-save nil))
   ;; First pass: identify buffers to save
   (dolist
    (buf (buffer-list))
    (let ((buf-name (buffer-name buf)))
      (when
       (and (logging--should-save-debug-buffer-p buf-name) (> (buffer-size buf) 0))
       (push (cons buf buf-name) buffers-to-save))))
   ;; Only create directory and save if we have buffers
   (when
    buffers-to-save
    (let ((saved-count 0))
      ;; Save each buffer using shared utility (with rotation)
      (dolist
       (buf-pair buffers-to-save)
       (let* ((buf (car buf-pair))
              (buf-name (cdr buf-pair))
              (safe-name (logging--sanitize-buffer-name buf-name))
              (log-filename (concat safe-name ".log")))
         (with-current-buffer
          buf
          (when
           (core-save-buffer-to-log
            buf-name log-filename debug-dir
            ;; Optional footer: add timestamp
            (lambda () (insert (format "\n;; Captured: %s\n" (current-time-string)))))
           (setq saved-count (1+ saved-count))))))
      ;; Report results
      (when
       (> saved-count 0)
       (logging-success
        "Auto-saved %d debug buffer%s with rotation"
        saved-count
        (if (> saved-count 1) "s" "")))))))

(defun
 logging-save-debug-buffers
 ()
 "Manually save debug buffers to ~/.emacs.d/local/log/debug/."
 (interactive)
 (logging--save-debug-buffers-on-exit))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Hook Registration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Messages buffer logging (always enabled)
(add-hook 'kill-emacs-hook #'logging--save-messages-buffer)

(provide 'logging-buffers)
;;; logging-buffers.el ends here
