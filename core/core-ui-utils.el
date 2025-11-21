;;; core-ui-utils.el --- UI and Window Management Utilities -*- lexical-binding: t -*-
;;; Commentary:
;; Utility functions for window management, buffer finding, and UI operations.

;;; Code:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 core-ui-utils-find-window-by-buffer-name (buffer-name-pattern &optional exact-match)
 "Find window displaying buffer matching BUFFER-NAME-PATTERN.
If EXACT-MATCH is non-nil, match buffer name exactly using string=.
Otherwise, use `string-prefix-p' for prefix matching (default).
Returns the window if found, nil otherwise.

Example:
  (core-ui-utils-find-window-by-buffer-name \"*Flymake diagnostics\")
  (core-ui-utils-find-window-by-buffer-name \"*Ilist*\" t)"
 (require 'cl-lib)
 (cl-find-if
  (lambda
   (window)
   (let ((buffer-name (buffer-name (window-buffer window))))
     (if
      exact-match
      (string= buffer-name-pattern buffer-name)
      (string-prefix-p buffer-name-pattern buffer-name))))
  (window-list)))

(defun
 core-ui-utils-close-window-by-buffer-name (buffer-name-pattern &optional exact-match)
 "Close window displaying buffer matching BUFFER-NAME-PATTERN.
If EXACT-MATCH is non-nil, match buffer name exactly using string=.
Otherwise, use `string-prefix-p' for prefix matching (default).
Returns t if window was found and closed, nil otherwise.

Example:
  (core-ui-utils-close-window-by-buffer-name \"*Flymake diagnostics\")
  (core-ui-utils-close-window-by-buffer-name \"*Ilist*\" t)"
 (let ((window (core-ui-utils-find-window-by-buffer-name buffer-name-pattern exact-match)))
   (when window (quit-window nil window) t)))

(defun
 core-ui-utils-resize-window-to-ratio (window width-ratio)
 "Resize WINDOW to WIDTH-RATIO of frame width.
WIDTH-RATIO is a decimal between 0.0 and 1.0 (e.g., 0.3 for 30%).
Calculates the desired width and resizes the window horizontally."
 (let* ((frame-width (frame-width))
        (desired-width (floor (* frame-width width-ratio)))
        (current-width (window-width window))
        (delta (- desired-width current-width)))
   (when (/= delta 0) (window-resize window delta t))))

(provide 'core-ui-utils)
;;; core-ui-utils.el ends here
