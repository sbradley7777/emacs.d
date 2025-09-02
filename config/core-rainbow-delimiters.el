;;; core-rainbow-delimiters.el --- Rainbow Delimiters Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Enhanced rainbow delimiters configuration with bold, high-visibility colors.
;;      Provides color-coded parentheses, brackets, and braces for better code navigation.

(defvar config-load-start-time (current-time))
(message "Loading core-rainbow-delimiters.el...")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Rainbow Delimiters Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package
 rainbow-delimiters
 :hook (prog-mode . rainbow-delimiters-mode)
 :config
 ;; Rainbow delimiters provides color-coded parentheses, brackets, and braces
 ;; Each nesting level gets a different color for better visual tracking

 ;; Enhanced visibility with bold faces and brighter colors
 (custom-set-faces
  ;; Level 1: Bold bright red
  '(rainbow-delimiters-depth-1-face ((t (:foreground "#ff6b6b" :weight bold))))
  ;; Level 2: Bold bright orange
  '(rainbow-delimiters-depth-2-face ((t (:foreground "#ffa500" :weight bold))))
  ;; Level 3: Bold bright yellow
  '(rainbow-delimiters-depth-3-face ((t (:foreground "#ffeb3b" :weight bold))))
  ;; Level 4: Bold bright green
  '(rainbow-delimiters-depth-4-face ((t (:foreground "#4caf50" :weight bold))))
  ;; Level 5: Bold bright cyan
  '(rainbow-delimiters-depth-5-face ((t (:foreground "#00bcd4" :weight bold))))
  ;; Level 6: Bold bright blue
  '(rainbow-delimiters-depth-6-face ((t (:foreground "#2196f3" :weight bold))))
  ;; Level 7: Bold bright purple
  '(rainbow-delimiters-depth-7-face ((t (:foreground "#9c27b0" :weight bold))))
  ;; Level 8: Bold bright magenta
  '(rainbow-delimiters-depth-8-face ((t (:foreground "#e91e63" :weight bold))))
  ;; Level 9: Bold bright pink (for very deep nesting)
  '(rainbow-delimiters-depth-9-face ((t (:foreground "#ff4081" :weight bold))))
  ;; Unmatched delimiter: Bold red with underline for visibility
  '(rainbow-delimiters-unmatched-face ((t (:foreground "#f44336" :weight bold :underline t))))
  ;; Mismatched delimiter: Bold red background for high visibility
  '(rainbow-delimiters-mismatched-face ((t (:foreground "#ffffff" :background "#f44336" :weight bold)))))

 (message "Rainbow delimiters configured with enhanced bold visibility"))

;; Make this module available for loading with (require 'core-rainbow-delimiters)
(provide 'core-rainbow-delimiters)
(message
 "core-rainbow-delimiters.el loaded (%.2fs)"
 (float-time (time-subtract (current-time) config-load-start-time)))
