;;; core-side-window-utils.el --- Side Window Toggle Utilities -*- lexical-binding: t -*-
;;; Commentary:
;;      Shared utilities for implementing consistent side window toggle behavior.
;;      Provides state tracking, window finding, and size cycling for side windows.
;;      All side windows cycle between compact (30%) and expanded (50%) widths.

;;; Code:
(require 'core-ui-utils)
(require 'features-constants)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar
 core-side-window-states (make-hash-table :test 'equal)
 "Hash table tracking width state for each side window.
Key: buffer-name-pattern (string).
Value: \\='compact or \\='expanded.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 core-side-window-get-state (buffer-pattern)
 "Get current width state for BUFFER-PATTERN window.
Returns \\='compact or \\='expanded, defaults to \\='compact if not set."
 (or (gethash buffer-pattern core-side-window-states) 'compact))

(defun
 core-side-window-set-state (buffer-pattern state)
 "Set width STATE for BUFFER-PATTERN window.
STATE should be \\='compact or \\='expanded."
 (puthash buffer-pattern state core-side-window-states))

(defun
 core-side-window-toggle-state (buffer-pattern)
 "Toggle width state for BUFFER-PATTERN between compact and expanded.
Returns the new state (\\='compact or \\='expanded)."
 (let ((current (core-side-window-get-state buffer-pattern)))
   (let ((new-state (if (eq current 'compact) 'expanded 'compact)))
     (core-side-window-set-state buffer-pattern new-state)
     new-state)))

(defun
 core-side-window-toggle (buffer-pattern open-fn &optional find-fn)
 "Generic toggle for side windows with size cycling.
BUFFER-PATTERN is string pattern to identify window (e.g., \"*Flymake diagnostics\").
OPEN-FN is function to call to open the window initially (takes no args).
FIND-FN is optional custom window finder, defaults to `core-find-window-by-buffer-name'.

Behavior:
- First press: Opens at 30% width (compact) with focus
- Second press: Expands to 50% width with focus
- Third press: Returns to 30% width
- Continues cycling on subsequent presses

Uses state tracking to remember width across invocations."
 (let* ((finder (or find-fn (lambda (pattern) (core-find-window-by-buffer-name pattern))))
        (existing-window (funcall finder buffer-pattern)))
   (if
    existing-window
    (progn
     (let ((new-state (core-side-window-toggle-state buffer-pattern)))
       (core-resize-window-to-ratio
        existing-window
        (if
         (eq new-state 'compact)
         features-side-window-compact-width
         features-side-window-expanded-width)))
     (select-window existing-window))
    (progn
     (funcall open-fn) (core-side-window-set-state buffer-pattern 'compact)
     (let ((new-window (funcall finder buffer-pattern)))
       (when new-window (select-window new-window)))))))

(provide 'core-side-window-utils)
;;; core-side-window-utils.el ends here
