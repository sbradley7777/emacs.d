;;; editing.el --- Editing Behavior Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Tabs, spaces, and general editing preferences

(defvar config-load-start-time (current-time))
(message "🔄  Loading editing.el...")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Enhanced editing preferences
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(electric-pair-mode 1) ; Auto-close parentheses
(delete-selection-mode 1) ; Replace selected text
(global-auto-revert-mode 1) ; Auto-reload changed files
(setq auto-revert-check-vc-info t) ; Include VC info in auto-revert

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Better indentation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; - http://www.emacswiki.org/emacs/NoTabs
(setq-default tab-width 4 standard-indent 4 indent-tabs-mode nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Line length and fill column configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Set maximum line length to 127 characters
(setq-default fill-column 127)

;; Enable visual line indicators for long lines
(setq whitespace-line-column 127)

;; Display fill column indicator (vertical line at column 127)
(global-display-fill-column-indicator-mode 1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Show whitespace and long lines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq whitespace-style '(face trailing tabs tab-mark lines-tail))
(global-whitespace-mode 1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Enhanced editing behavior
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Better undo/redo behavior - comprehensive undo buffer configuration
(setq
 undo-limit 6000000 ; Normal undo entries kept in memory (6MB)
 undo-strong-limit 9000000 ; Strongly-held undo entries (9MB)
 undo-outer-limit 12000000) ; Maximum undo data before old entries are discarded (12MB)

;; Smarter beginning-of-line behavior
(defun
 smart-beginning-of-line () "Move to beginning of line or indentation." (interactive)
 (let ((oldpos (point)))
   (back-to-indentation)
   (and (= oldpos (point)) (beginning-of-line))))

(global-set-key (kbd "C-a") 'smart-beginning-of-line)


;; Make this module available for loading with (require 'editing)
(provide 'editing)
(message
 "editing.el loaded (%.2fs)" (float-time (time-subtract (current-time) config-load-start-time)))
