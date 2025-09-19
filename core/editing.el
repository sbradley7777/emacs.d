;;; editing.el --- Editing Behavior Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Tabs, spaces, and general editing preferences

(require 'core-constants)
(require 'core-utils)

(core-utils-with-load-timing
 "editing.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Enhanced editing preferences
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (electric-pair-mode 1) ; Auto-close parentheses
 (delete-selection-mode 1) ; Replace selected text
 (global-auto-revert-mode 1) ; Auto-reload changed files
 (setq auto-revert-check-vc-info t) ; Include VC info in auto-revert

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Better indentation
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; - http://www.emacswiki.org/emacs/NoTabs
 (setq-default tab-width core-tab-width standard-indent core-standard-indent indent-tabs-mode nil)

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Line length and fill column configuration
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Set maximum line length using core constant
 (setq-default fill-column core-fill-column)

 ;; Enable visual line indicators for long lines
 (setq whitespace-line-column core-fill-column)

 ;; Display fill column indicator (vertical line at configured column)
 (global-display-fill-column-indicator-mode 1)

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Show whitespace and long lines
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (setq whitespace-style '(face trailing tabs tab-mark lines-tail)) (global-whitespace-mode 1)

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Enhanced editing behavior
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Better undo/redo behavior - comprehensive undo buffer configuration
 (setq
  undo-limit core-undo-limit ; Normal undo entries kept in memory
  undo-strong-limit core-undo-strong-limit ; Strongly-held undo entries
  undo-outer-limit core-undo-outer-limit) ; Maximum undo data before old entries are discarded

 ;; Make this module available for loading with (require 'editing)
 (provide 'editing))
