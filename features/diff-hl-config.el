;;; diff-hl-config.el --- Git Diff Highlighting Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Visual indicators for git changes in the fringe.
;;      Shows added, modified, and deleted lines with colored bars.
;;      Works passively alongside terminal git workflow.

(require 'core-utils)

(core-utils-with-load-timing
 "diff-hl-config.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; diff-hl Configuration
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (use-package
  diff-hl
  :config
  ;; Enable diff-hl in all file-visiting buffers
  (global-diff-hl-mode 1)

  ;; Highlight changes on-the-fly (updates as you edit)
  (diff-hl-flydiff-mode 1)

  ;; Use margin mode in terminal, fringe mode in GUI
  (unless
   (display-graphic-p)
   ;; Enable margin mode for terminal
   (diff-hl-margin-mode 1)
   ;; Customize margin symbols to show characters with colors
   (setq diff-hl-margin-symbols-alist '((insert . "+") (delete . "-") (change . "~")))
   ;; Customize faces to use doom-1337 theme colors (foreground only, no background)
   ;; Color scheme matches modeline and theme aesthetic for visual consistency:
   ;;   - insert (green):  #7bc275 - same as doom-1337-color-green (success states)
   ;;   - delete (red):    #f0a0a0 - same as doom-1337-color-red (error states)
   ;;   - change (yellow): #ffe66d - same as doom-1337-color-yellow (modified/attention states)
   ;; Background set to unspecified ensures symbols display with colored text only, not colored blocks
   (custom-set-faces
    '(diff-hl-insert ((t (:foreground "#7bc275" :background unspecified)))) ; Green (matches theme success)
    '(diff-hl-delete ((t (:foreground "#f0a0a0" :background unspecified)))) ; Coral red (matches theme errors)
    '(diff-hl-change ((t (:foreground "#ffe66d" :background unspecified))))))

  ;; Update diff indicators after save
  (add-hook 'after-save-hook #'diff-hl-update)

  ;; Enable in dired buffers to show file status
  (add-hook 'dired-mode-hook #'diff-hl-dired-mode)

  ;; Refresh diff-hl when magit refreshes (if magit is ever added)
  (with-eval-after-load 'magit (add-hook 'magit-post-refresh-hook #'diff-hl-magit-post-refresh))))

(provide 'diff-hl-config)

;;; diff-hl-config.el ends here
