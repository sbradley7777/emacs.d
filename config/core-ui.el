;;; core-ui.el --- User Interface Configuration
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

;; Modern line number display
(global-display-line-numbers-mode 1)
(setq display-line-numbers-type 'relative)

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
;; Set title
(setq-default frame-title-format (list "My Emacs %b: %f"))
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

(provide 'core-ui)
(message "core-ui.el loaded successfully.")
