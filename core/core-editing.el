;;; core-editing.el --- Editing Behavior Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Tabs, spaces, and general editing preferences

(require 'core-constants)
(require 'core-utils)

(core-utils-with-load-timing
 "core-editing.el"

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
 ;; Show whitespace (without line length highlighting)
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (setq whitespace-style '(face trailing tabs tab-mark)) (global-whitespace-mode 1)

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Enhanced editing behavior
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Better undo/redo behavior - comprehensive undo buffer configuration
 (setq
  undo-limit core-undo-limit ; Normal undo entries kept in memory
  undo-strong-limit core-undo-strong-limit ; Strongly-held undo entries
  undo-outer-limit core-undo-outer-limit) ; Maximum undo data before old entries are discarded

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Clipboard integration
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Enable clipboard integration for terminal mode using OSC 52 escape sequences.
 ;; This allows copying from Emacs in terminal mode to the system clipboard over SSH.
 (unless
  (display-graphic-p)
  (setq select-enable-clipboard t select-enable-primary t save-interprogram-paste-before-kill t)

  ;; Configure OSC 52 clipboard support for terminal
  (defun
   osc-52-copy (text) "Copy TEXT to system clipboard using OSC 52 escape sequence."
   (let ((encoded (base64-encode-string text t)))
     (send-string-to-terminal (concat "\e]52;c;" encoded "\a"))))

  ;; Hook into Emacs clipboard system
  (setq interprogram-cut-function 'osc-52-copy))

 ;; Make this module available for loading with (require 'core-editing)
 (provide 'core-editing))
