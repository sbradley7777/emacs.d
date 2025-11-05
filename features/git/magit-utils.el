;;; magit-utils.el --- Magit-specific utility functions -*- lexical-binding: t -*-

;;; Commentary:
;;      Magit-specific helper functions for buffer display and formatting.
;;      Provides customized display and formatting behavior for Magit buffers.
(require 'core-utils)
(require 'features-constants)
(require 'git-constants)
(core-utils-with-load-timing
 "magit-utils.el"
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Magit Buffer Display
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  magit-utils-display-buffer-side (buffer) "Display BUFFER in side window at configured width."
  (display-buffer
   buffer
   `(display-buffer-in-side-window (side . right) (window-width . ,features-side-window-width))))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Magit Buffer Formatting
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  magit-utils-format-buffer () "Format Magit buffer with word-wrapped lines and proper padding."
  (let ((inhibit-read-only t)
        (win-width (window-width)))
    (save-excursion
     (goto-char (point-min))
     (while
      (re-search-forward "^\\(Head:\\|Merge:\\|Push:\\|Pull:\\)\\s-+" nil t)
      (let* ((label-end (point))
             (line-end (line-end-position))
             (fill-prefix (make-string (current-column) ?\s))
             (fill-column (- win-width magit-format-fill-margin)))
        (when
         (> (- line-end (line-beginning-position)) fill-column)
         (fill-region-as-paragraph label-end line-end)))))))

 (core-message-config "Magit utility functions loaded"))
(provide 'magit-utils)
;;; magit-utils.el ends here
