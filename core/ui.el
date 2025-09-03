;;; ui.el --- User Interface Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Display preferences and UI behavior

(require 'core-constants)

(defvar config-load-start-time (current-time))
(message "🔄  Loading ui.el...")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; UI Elements Control:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Disable UI elements for cleaner interface
(when (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(when (fboundp 'menu-bar-mode) (menu-bar-mode -1))

;; Modern line number display with performance optimizations
;; Use visual line numbers for better performance with large files
(when
 (version<= "26.0.50" emacs-version) (global-display-line-numbers-mode 1)
 (setq display-line-numbers-type 'visual) ; More efficient than 'relative
 (setq display-line-numbers-width-start t) ; Dynamic width calculation
 (setq display-line-numbers-grow-only t) ; Prevent width flickering
 ;; Disable line numbers in certain modes for better performance
 (dolist
  (mode '(org-mode-hook term-mode-hook shell-mode-hook eshell-mode-hook treemacs-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load Misc Preferences:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Display the time
(display-time)
;; Don't show the GNU splash screen
(setq inhibit-startup-message t)
;; Search and line/column display preferences - consolidated for efficiency
(setq
 case-fold-search t ; Make searches case insensitive
 column-number-mode t) ; Add column numbers to mode line
(line-number-mode 1) ; Show current line number in mode line (mode function, not variable)
;; Basic editor behavior
(set-default 'truncate-lines t) ; Don't word wrap long lines
(setq-default scroll-step core-scroll-step) ; Turn off jumpy scroll
(setq ring-bell-function 'ignore) ; Better than visible-bell
(global-hl-line-mode 1) ; Highlight current line
;; Additional editor preferences
(setq-default
 transient-mark-mode t ; Visual feedback on
 kill-whole-line t ; ctrl-k kills whole line if at col 0
 show-trailing-whitespace t) ; Highlight trailing whitespaces
;; Enhanced title bar showing buffer name and file path with hostname
(setq
 frame-title-format '("%b - " (:eval (or (file-remote-p default-directory 'host) system-name))))
;; File handling preferences
(setq
 diff-default-read-only nil ; Turn off read only mode with .patch files
 vc-follow-symlinks t ; Follow symlinks and don't ask
 require-final-newline t) ; Always end a file with a newline
;; Show matching parenthesis
(show-paren-mode 1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Enhanced UI features
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Better window management with winner-mode (undo/redo window configurations)
(winner-mode 1)

;; Improved parentheses highlighting with better colors and delay
(setq
 show-paren-delay core-show-paren-delay ; Faster highlighting
 show-paren-style 'parenthesis) ; Only highlight the parentheses themselves

;; Enhanced scrolling behavior
(setq
 scroll-conservatively core-scroll-conservatively ; Smooth scrolling
 scroll-preserve-screen-position t) ; Keep cursor position when scrolling

;; Better buffer switching
(setq switch-to-buffer-preserve-window-point t)

;; More informative mode line
(setq size-indication-mode t) ; Show buffer size in mode line

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Modern Emacs features
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Save command history
(savehist-mode 1)
(setq savehist-additional-variables '(search-ring regexp-search-ring))

;; Track recently opened files
(recentf-mode 1)
(setq
 recentf-max-saved-items
 core-recentf-max-items
 recentf-exclude
 '("~/.emacs.d/elpa/.*" "/tmp/.*" "/ssh:.*"))

(normal-erase-is-backspace-mode 0)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Enhanced cursor and interaction behavior
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Better cursor and selection visibility
(setq-default cursor-type 'box) ; Box cursor for better visibility
(blink-cursor-mode -1) ; Disable cursor blinking
(setq mouse-yank-at-point t) ; Paste at cursor, not mouse position

;; Make this module available for loading with (require 'ui)
(provide 'ui)
(message "ui.el loaded (%.2fs)" (float-time (time-subtract (current-time) config-load-start-time)))
