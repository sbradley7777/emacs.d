;;; rainbow-delimiters-config.el --- Rainbow Delimiters Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Enhanced rainbow delimiters configuration with bold, high-visibility colors.
;;      Provides color-coded parentheses, brackets, and braces for better code navigation.
(require 'core-utils)
(require 'core-logging)
(require 'features-constants)
(core-utils-with-load-timing
 "rainbow-delimiters-config.el"
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Rainbow Delimiters Configuration
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Ensure package system is initialized
 (unless package--initialized (package-initialize))
 (use-package
  rainbow-delimiters
  :ensure t
  :hook (prog-mode . rainbow-delimiters-mode)
  :config
  ;; Rainbow delimiters provides color-coded parentheses, brackets, and braces
  ;; Each nesting level gets a different color for better visual tracking

  ;; Enhanced visibility with bold faces and brighter colors
  (custom-set-faces
   ;; Level 1: Bold bright red
   `(rainbow-delimiters-depth-1-face ((t (:foreground ,features-color-delimiter-1 :weight bold))))
   ;; Level 2: Bold bright orange
   `(rainbow-delimiters-depth-2-face ((t (:foreground ,features-color-delimiter-2 :weight bold))))
   ;; Level 3: Bold bright yellow
   `(rainbow-delimiters-depth-3-face ((t (:foreground ,features-color-delimiter-3 :weight bold))))
   ;; Level 4: Bold bright green
   `(rainbow-delimiters-depth-4-face ((t (:foreground ,features-color-delimiter-4 :weight bold))))
   ;; Level 5: Bold bright cyan
   `(rainbow-delimiters-depth-5-face ((t (:foreground ,features-color-delimiter-5 :weight bold))))
   ;; Level 6: Bold bright blue
   `(rainbow-delimiters-depth-6-face ((t (:foreground ,features-color-delimiter-6 :weight bold))))
   ;; Level 7: Bold bright purple
   `(rainbow-delimiters-depth-7-face ((t (:foreground ,features-color-delimiter-7 :weight bold))))
   ;; Level 8: Bold bright magenta
   `(rainbow-delimiters-depth-8-face ((t (:foreground ,features-color-delimiter-8 :weight bold))))
   ;; Level 9: Bold bright pink (for very deep nesting)
   `(rainbow-delimiters-depth-9-face ((t (:foreground ,features-color-delimiter-9 :weight bold))))
   ;; Unmatched delimiter: Bold red with underline for visibility
   `(rainbow-delimiters-unmatched-face
     ((t (:foreground ,features-color-delimiter-unmatched :weight bold :underline t))))
   ;; Mismatched delimiter: Bold red background for high visibility
   `(rainbow-delimiters-mismatched-face
     ((t
       (:foreground
        ,features-color-delimiter-error-fg
        :background ,features-color-delimiter-error-bg
        :weight bold)))))

  (core-message-config "Rainbow delimiters configured with enhanced bold visibility")))
(provide 'rainbow-delimiters-config)
