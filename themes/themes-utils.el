;;; themes-utils.el --- Theme Utilities and Interactive Tools -*- lexical-binding: t -*-
;;; Commentary:
;; WHAT: Interactive theme switching and browsing utilities
;; WHY:  Provides advanced theme management features separate from core loading
;; PROVIDES: theme-utils-switch-theme, toggle-list-themes-window, theme preview functionality
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Advanced theme utilities for interactive theme management
;; Core theme loading is handled by themes-config.el

;;; Code:
(require 'core-utils)
(require 'logging-init)
(require 'themes-config)
(require 'core-side-window-utils)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 themes--utils-apply-doom-customizations
 ()
 "Apply doom-themes-specific customizations."
 (require 'doom-themes)
 (dolist (custom themes-config-doom-default-customizations) (set (car custom) (cdr custom)))

 ;; Enable doom-themes enhancements (with error handling for terminal compatibility)
 (condition-case err
     (progn (doom-themes-visual-bell-config) (doom-themes-org-config))
   (error
    (logging-warning
     "Some doom-themes features disabled for terminal compatibility: %s"
     (error-message-string err)))))

(defun
 themes--utils-apply-customizations (theme) "Apply customizations for the specified THEME."
 ;; Apply doom-themes configuration for all themes
 (themes--utils-apply-doom-customizations)
 ;; Apply any user customizations from local.el
 (when-let ((customs (cdr (assq theme themes-config-customizations))))
   (dolist (custom customs) (set (car custom) (cdr custom)))))

(defun
 themes--utils-get-available-doom-themes () "Get a list of all available doom themes."
 (sort
  (seq-filter
   (lambda (theme) (string-match-p "^doom-" (symbol-name theme))) (custom-available-themes))
  (lambda (a b) (string< (symbol-name a) (symbol-name b)))))

(defun
 themes--utils-get-other-themes
 ()
 "Get a list of other (non-doom) themes that work well."
 '(wombat tango-dark leuven))

;;;###autoload
(defun
 theme-utils-switch-theme
 (theme)
 "Interactively switch to a different THEME."
 (interactive
  (list
   (intern
    (completing-read
     "Select theme: "
     (append
      (mapcar #'symbol-name (themes--utils-get-available-doom-themes))
      (mapcar #'symbol-name (themes--utils-get-other-themes)))
     nil t nil nil "doom-zenburn"))))
 (logging-theme "Interactive theme switch requested: %s" theme)
 (setq themes-config-preferred-theme theme)
 (themes-config-load-configured-theme)
 (logging-success "Theme switched to: %s" theme))

(defun
 themes--utils-setup-buffer-content ()
 "Create and populate the themes list buffer content, then display it.
Returns the buffer name."
 (let* ((doom-themes (themes--utils-get-available-doom-themes))
        (other-themes (themes--utils-get-other-themes))
        (current-theme (car custom-enabled-themes))
        (buffer-name "*Available Themes*")
        (lines '()))
   (logging-theme "Opening theme browser...")
   ;; Collect all lines
   (push "Available Themes:" lines)
   (push "==================" lines)
   (push "" lines)
   (push "Click on a theme name or press 'RET' to select it, 'q' to quit." lines)
   (push "" lines)
   (push "DOOM THEMES:" lines)
   ;; Sort doom-themes with current theme first
   (let ((sorted-doom-themes
          (if
           (and current-theme (memq current-theme doom-themes))
           (cons current-theme (remove current-theme doom-themes))
           doom-themes)))
     (dolist
      (theme sorted-doom-themes)
      (let ((line
             (if
              (eq theme current-theme) (format "-> %s (current)" theme) (format "   %s" theme))))
        (push line lines))))
   (push "" lines)
   (push "OTHER THEMES:" lines)
   ;; Sort other-themes with current theme first
   (let ((sorted-other-themes
          (if
           (and current-theme (memq current-theme other-themes))
           (cons current-theme (remove current-theme other-themes))
           other-themes)))
     (dolist
      (theme sorted-other-themes)
      (let ((line
             (if
              (eq theme current-theme) (format "-> %s (current)" theme) (format "   %s" theme))))
        (push line lines))))
   ;; Create or update buffer
   (with-current-buffer
    (get-buffer-create buffer-name)
    (let ((inhibit-read-only t))
      (erase-buffer)
      (dolist (line (reverse lines)) (insert line) (insert "\n")))
    ;; Set up keybindings
    (let ((select-theme-fn
           (lambda
            () (interactive)
            (let ((line (thing-at-point 'line t)))
              (when
               (string-match "\\(?:-> \\|   \\)\\([a-z0-9-]+\\)" line)
               (let ((theme (intern (match-string 1 line))))
                 (logging-theme "Theme selection: %s" theme)
                 (setq themes-config-preferred-theme theme)
                 (themes-config-load-configured-theme)
                 (logging-success "Switched to theme: %s (buffer stays open for testing)" theme)
                 ;; Update the buffer to show new current theme
                 (toggle-list-themes-window)))))))
      (local-set-key (kbd "RET") select-theme-fn)
      (local-set-key (kbd "q") 'quit-window)
      (local-set-key (kbd "C-g") 'quit-window)
      (setq buffer-read-only t))
    (goto-char (point-min)))
   ;; Display buffer in side window
   (display-buffer buffer-name '(display-buffer-in-side-window (side . right)))
   buffer-name))

;;;###autoload
(defun
 toggle-list-themes-window
 ()
 "Toggle themes list window with size cycling between 30% and 50% width.
When buffer is closed, opens at 30%.  When buffer is open, toggles between 30% and 50%.

Shows doom-themes and built-in Emacs themes in a dedicated side window.
Press RET on a theme name to preview it immediately.  The currently
active theme is highlighted.  Provides a visual way to browse and
test different color schemes."
 (interactive)
 (core-side-window-toggle "*Available Themes*" (lambda () (themes--utils-setup-buffer-content))))

;; Make this module available for loading with (require 'themes-utils)
(provide 'themes-utils)
;;; themes-utils.el ends here
