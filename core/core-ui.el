;;; core-ui.el --- User Interface Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Display preferences and UI behavior

;;; Code:
(require 'core-constants)

;; Declare external variables to suppress byte-compiler warnings
(defvar display-line-numbers-type) ; From display-line-numbers.el
(defvar display-line-numbers-width-start) ; From display-line-numbers.el
(defvar display-line-numbers-grow-only) ; From display-line-numbers.el
(defvar diff-default-read-only) ; From diff-mode.el
(defvar show-paren-delay) ; From paren.el
(defvar show-paren-style) ; From paren.el
(defvar savehist-file) ; From savehist.el
(defvar savehist-additional-variables) ; From savehist.el
(defvar recentf-save-file) ; From recentf.el
(defvar recentf-max-saved-items) ; From recentf.el
(defvar recentf-exclude) ; From recentf.el
(defvar recentf-auto-cleanup) ; From recentf.el
(defvar recentf-auto-save-timer) ; From recentf.el

;; Declare external functions to suppress byte-compiler warnings
(declare-function recentf-load-list "recentf" ())
(declare-function recentf-save-list "recentf" ())

;; Modern line number display (Emacs 30.2+)
(global-display-line-numbers-mode 1)
(setq
 display-line-numbers-type t display-line-numbers-width-start t display-line-numbers-grow-only t)

;; Disable in certain modes for performance
(dolist
 (mode '(org-mode-hook term-mode-hook shell-mode-hook eshell-mode-hook treemacs-mode-hook))
 (add-hook mode (lambda () (display-line-numbers-mode 0))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load Misc Preferences:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Don't show the GNU splash screen
(setq inhibit-startup-message t)

;; Initial buffer choice: show dashboard only when no files specified
(setq
 initial-buffer-choice
 (lambda
  () (if (> (length command-line-args) 1) (current-buffer) (get-buffer-create "*dashboard*"))))

;; Prevent window splitting when opening multiple files from command line
;; Only show the first file, keep others in background buffers
(add-hook
 'window-setup-hook (lambda () (when (> (length command-line-args) 1) (delete-other-windows))))

;; Search preferences
(setq case-fold-search t) ; Make searches case insensitive
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
;; Disable trailing whitespace highlighting in Messages buffer
(with-current-buffer "*Messages*" (setq-local show-trailing-whitespace nil))
(add-hook 'messages-buffer-mode-hook (lambda () (setq-local show-trailing-whitespace nil)))
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Modern Emacs features
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Save command history
(setq savehist-file core-savehist-file)
(savehist-mode 1)
(setq savehist-additional-variables '(search-ring regexp-search-ring))

;; Track recently opened files
(setq recentf-save-file core-recentf-file)
(recentf-mode 1)
;; Ensure recentf loads existing list on startup
(recentf-load-list)
(setq recentf-max-saved-items core-recentf-max-items recentf-exclude '(".*/elpa/.*" "/tmp/.*"))

;; Auto-save recentf list every 30 seconds when idle
(setq recentf-auto-cleanup 'never)
(setq
 recentf-auto-save-timer
 (run-with-idle-timer
  30 t
  (lambda
   ()
   (let ((_recentf-auto-cleanup 'never))
     (recentf-save-list)))))

(normal-erase-is-backspace-mode 0)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Enhanced cursor and interaction behavior
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Better cursor and selection visibility
(setq-default cursor-type 'box) ; Box cursor for better visibility
(blink-cursor-mode -1) ; Disable cursor blinking
(setq mouse-yank-at-point t) ; Paste at cursor, not mouse position

;; Enable xterm mouse mode for consistent mouse selection in terminal
(unless (display-graphic-p) (xterm-mouse-mode 1))
(provide 'core-ui)
;;; core-ui.el ends here
