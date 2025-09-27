;;; gui-mode-functions.el --- GUI Mode Utility Functions -*- lexical-binding: t -*-
;;; Commentary:
;;      Utility functions for GUI mode operations and window management.

(require 'core-constants)
(require 'core-utils)

(core-utils-with-load-timing
 "gui-mode-functions.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Window Refresh Functions
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (defun
  ui-auto-refresh (&rest args)
  "Automatically refresh display after any window changes.
Triggers on resize, fullscreen, maximize, minimize, and focus events.
ARGS can contain frame parameter from various hooks, handled safely."
  (condition-case err
      (let ((frame (if (and args (framep (car args))) (car args) (selected-frame))))
        (when
         (display-graphic-p)
         ;; In GUI mode, use faster refresh with minimal delay
         (run-with-timer 0.05 nil (lambda () (redraw-frame frame) (force-window-update frame))))
        (unless
         (display-graphic-p)
         ;; In terminal mode, immediate refresh is fine
         (redraw-display) (force-window-update) (redraw-frame frame)))
    (error
     (message "❌  UI refresh failed: %s" (error-message-string err)))))

 (defun
  ui-force-refresh () "Force an immediate UI refresh for manual triggers." (interactive)
  (condition-case err
      (let ((frame (selected-frame)))
        (if
         (display-graphic-p)
         ;; In GUI mode, minimal delay to prevent flicker
         (run-with-timer
          0.02 nil
          (lambda () (redraw-frame frame) (force-window-update frame) (redraw-display)))
         ;; In terminal mode, immediate refresh
         (redraw-display) (force-window-update) (redraw-frame frame)))
    (error
     (message "❌  Manual UI refresh failed: %s" (error-message-string err)))))

 ;; Make this module available for loading with (require 'gui-mode-functions)
 (provide 'gui-mode-functions))
