;;; indent-guides.el --- Visual Indentation Guides Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Visual indentation guides using highlight-indent-guides.
;;      Provides column-based indentation visualization for better code structure understanding.

(defvar config-load-start-time (current-time))
(message "🔄  Loading indent-guides.el...")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Highlight Indent Guides Configuration
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
 (setq highlight-indent-guides-auto-character-face-perc 40) ; More visible base guides
 (setq highlight-indent-guides-auto-top-character-face-perc 80) ; Very visible current scope

 ;; Define custom faces for better visibility
 (custom-set-faces
  '(highlight-indent-guides-odd-face ((t (:background "#2a2a2a"))))
  '(highlight-indent-guides-even-face ((t (:background "#3a3a3a"))))
  '(highlight-indent-guides-character-face ((t (:foreground "#4a4a4a"))))
  '(highlight-indent-guides-top-odd-face ((t (:background "#404040"))))
  '(highlight-indent-guides-top-even-face ((t (:background "#505050"))))
  '(highlight-indent-guides-top-character-face ((t (:foreground "#707070")))))

 ;; Delay before updating guides (performance optimization)
 (setq highlight-indent-guides-delay 0.1)

 ;; Enable guides to work properly with blank lines
 (setq highlight-indent-guides-suppress-auto-error t)

 (message "⚙️  Highlight indent guides configured with column method and responsive highlighting"))

;; Make this module available for loading with (require 'indent-guides)
(provide 'indent-guides)
(message
 "indent-guides.el loaded (%.2fs)"
 (float-time (time-subtract (current-time) config-load-start-time)))
