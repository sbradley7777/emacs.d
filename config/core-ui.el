;;; core-ui.el --- User Interface Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Display preferences and UI behavior

(message "Loading core-ui.el...")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; UI Elements Control:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Disable UI elements for cleaner interface
(when (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(when (fboundp 'menu-bar-mode) (menu-bar-mode -1))

;; Modern line number display with performance optimizations
;; Use visual line numbers for better performance with large files
(when (version<= "26.0.50" emacs-version)
  (global-display-line-numbers-mode 1)
  (setq display-line-numbers-type 'visual) ; More efficient than 'relative
  ;; Disable line numbers in certain modes for better performance
  (dolist (mode '(org-mode-hook
                  term-mode-hook
                  shell-mode-hook
                  eshell-mode-hook
                  treemacs-mode-hook))
    (add-hook mode (lambda () (display-line-numbers-mode 0)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load Misc Prefrences:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Display the time
(display-time)
;; Dont show the GNU splash screen
(setq inhibit-startup-message t)
;; Make searches case insensitive
(setq case-fold-search t)
;; Current line & column number of cursor in the mode line
(line-number-mode 1)
;; Add column numbers
(setq column-number-mode t)
;; Don't word wrap long lines
(set-default 'truncate-lines t)
;; Turn off jumpy scroll
(setq-default scroll-step 1)
;; Better defaults
(setq ring-bell-function 'ignore)  ; Better than visible-bell
(global-hl-line-mode 1)           ; Highlight current line
;; Visual feedback on
(setq-default transient-mark-mode t)
;; The ctrl-k kills whole line if at col 0
(setq-default kill-whole-line t)
;; Highlights trailing whitespaces
(setq-default show-trailing-whitespace t)
;; Enhanced title bar showing buffer name and file path with hostname
(setq frame-title-format '("%b - " (:eval (or (file-remote-p default-directory 'host) system-name))))
;; Turn off read only mode with .patch files
(setq diff-default-read-only nil)
;; Follow symlinks and don't ask.
(setq vc-follow-symlinks t)
;; Always end a file with a newline, t to enable
(setq require-final-newline t)
;; Wrap at col 70
(setq-default fill-column 127)
;; Show matching parenthesis
(show-paren-mode 1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Enhanced UI features
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Better window management with winner-mode (undo/redo window configurations)
(winner-mode 1)

;; Improved parentheses highlighting with better colors and delay
(setq show-paren-delay 0.1)  ; Faster highlighting
(setq show-paren-style 'parenthesis)  ; Only highlight the parentheses themselves

;; Enhanced scrolling behavior
(setq scroll-conservatively 10000)  ; Smooth scrolling
(setq scroll-preserve-screen-position t)  ; Keep cursor position when scrolling

;; Better buffer switching
(setq switch-to-buffer-preserve-window-point t)

;; More informative mode line
(setq size-indication-mode t)  ; Show buffer size in mode line

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Modern Emacs features
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Save command history
(savehist-mode 1)
(setq savehist-additional-variables '(search-ring regexp-search-ring))

;; Track recently opened files
(recentf-mode 1)
(setq recentf-max-saved-items 50)
(setq recentf-exclude '("~/.emacs.d/elpa/.*" "/tmp/.*" "/ssh:.*"))

(normal-erase-is-backspace-mode 0)

;; Make this module available for loading with (require 'core-ui)
(provide 'core-ui)
(message "core-ui.el loaded successfully.")
