;;; ui.el --- User Interface Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Display preferences and UI behavior


(core-utils-with-load-timing
 "ui.el"


 ;; Modern line number display (Emacs 30.2+)
 (global-display-line-numbers-mode 1)
 (setq
  display-line-numbers-type t display-line-numbers-width-start t display-line-numbers-grow-only t)

 ;; Disable in certain modes for performance
 (dolist
  (mode '(org-mode-hook term-mode-hook shell-mode-hook eshell-mode-hook treemacs-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Load Misc Preferences:
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Enhanced UI features
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

 ;; Add custom Python virtual environment indicator to mode line
 (add-to-list
  'mode-line-misc-info
  '(:eval
    (when
     (and
      (local-variable-p 'pyvenv-current-project-name)
      pyvenv-current-project-name
      (not (string= pyvenv-current-project-name "inactive")))
     (propertize
      (concat
       "[venv: " pyvenv-current-project-name
       (when pyvenv-current-version (concat " (py" pyvenv-current-version ")")) "] ")
      'face
      (when
       (and
        (boundp 'pyvenv-modeline-color) pyvenv-modeline-color)
       `(:foreground ,pyvenv-modeline-color))))))

 ;; Add username and hostname to mode line (non-destructive approach)
 (add-to-list
  'mode-line-misc-info
  '(:eval
    (concat
     "[" (user-login-name) "@" (or (file-remote-p default-directory 'host) (system-name)) "] ")))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Modern Emacs features
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Save command history
 (setq savehist-file (expand-file-name "history" emacs-local-dir))
 (savehist-mode 1)
 (setq savehist-additional-variables '(search-ring regexp-search-ring))

 ;; Track recently opened files
 (setq recentf-save-file (expand-file-name "recentf" emacs-local-dir))
 (recentf-mode 1)
 ;; Ensure recentf loads existing list on startup
 (recentf-load-list)
 (setq
  recentf-max-saved-items
  core-recentf-max-items
  recentf-exclude
  `(,(expand-file-name "elpa/.*" emacs-local-dir) "/tmp/.*"))

 ;; Auto-save recentf list every 30 seconds when idle
 (setq recentf-auto-cleanup 'never)
 (setq
  recentf-auto-save-timer
  (run-with-idle-timer
   30 t
   (lambda
    ()
    (let ((recentf-auto-cleanup 'never))
      (recentf-save-list)))))


 (normal-erase-is-backspace-mode 0)

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Enhanced cursor and interaction behavior
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Better cursor and selection visibility
 (setq-default cursor-type 'box) ; Box cursor for better visibility
 (blink-cursor-mode -1) ; Disable cursor blinking
 (setq mouse-yank-at-point t) ; Paste at cursor, not mouse position

 ;; Enable xterm mouse mode for consistent mouse selection in terminal
 (unless (display-graphic-p) (xterm-mouse-mode 1))


 ;; Make this module available for loading with (require 'ui)
 (provide 'ui))
