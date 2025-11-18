;;; highlight-indent-guides-config.el --- Visual Indentation Guides Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Visual indentation guides using highlight-indent-guides.
;;      Provides column-based indentation visualization for better code structure understanding.

;;; Code:
(require 'core-logging)
(require 'features-constants)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package
 highlight-indent-guides
 :hook (prog-mode . highlight-indent-guides-mode)
 :config
 ;; Use column method for full-column highlighting of indentation levels
 ;; Manual colors ensure visibility with all themes
 (setq highlight-indent-guides-method 'column)

 ;; Enable responsive guides - highlights current scope context
 (setq highlight-indent-guides-responsive 'top)

 ;; Disable auto-calculation and use manual colors for better visibility
 (setq highlight-indent-guides-auto-enabled nil)

 ;; Manual color configuration for better visibility
 ;; Set specific colors that work well with both light and dark themes
 (setq
  highlight-indent-guides-auto-character-face-perc
  features-indent-guides-auto-char-face-perc) ; More visible base guides
 (setq
  highlight-indent-guides-auto-top-character-face-perc
  features-indent-guides-auto-top-char-face-perc) ; Very visible current scope

 ;; Define custom faces for better visibility
 (custom-set-faces
  `(highlight-indent-guides-odd-face ((t (:background ,features-color-indent-guide-odd))))
  `(highlight-indent-guides-even-face ((t (:background ,features-color-indent-guide-even))))
  `(highlight-indent-guides-character-face ((t (:foreground ,features-color-indent-guide-char))))
  `(highlight-indent-guides-top-odd-face ((t (:background ,features-color-indent-guide-top-odd))))
  `(highlight-indent-guides-top-even-face
    ((t (:background ,features-color-indent-guide-top-even))))
  `(highlight-indent-guides-top-character-face
    ((t (:foreground ,features-color-indent-guide-top-char)))))

 ;; Delay before updating guides (performance optimization)
 (setq highlight-indent-guides-delay features-indent-guides-delay)

 ;; Enable guides to work properly with blank lines
 (setq highlight-indent-guides-suppress-auto-error t)
 (core-message-config
  "Highlight indent guides configured with column method and responsive highlighting"))
(provide 'highlight-indent-guides-config)
;;; highlight-indent-guides-config.el ends here
