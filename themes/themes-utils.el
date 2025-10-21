;;; themes-utils.el --- Theme Utilities and Interactive Tools -*- lexical-binding: t -*-
;;; Commentary:
;; WHAT: Interactive theme switching and browsing utilities
;; WHY:  Provides advanced theme management features separate from core loading
;; PROVIDES: switch-theme, list-themes, theme preview functionality
;;
;; Advanced theme utilities for interactive theme management
;; Core theme loading is handled by themes-config.el

(require 'core-utils)
(require 'core-logging)
(require 'themes-config)

(core-utils-with-load-timing
 "themes-utils.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Generic Theme Customization Functions
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (defun
  themes-utils--apply-doom-customizations
  ()
  "Apply doom-themes-specific customizations."
  (require 'doom-themes)
  (dolist (custom themes-config-doom-default-customizations) (set (car custom) (cdr custom)))

  ;; Enable doom-themes enhancements (with error handling for terminal compatibility)
  (condition-case err
      (progn (doom-themes-visual-bell-config) (doom-themes-org-config))
    (error
     (core-message-warning
      "Some doom-themes features disabled for terminal compatibility: %s"
      (error-message-string err)))))

 (defun
  themes-utils--apply-customizations (theme) "Apply customizations for the specified THEME."
  ;; Apply doom-themes configuration for all themes
  (themes-utils--apply-doom-customizations)
  ;; Apply any user customizations from local.el
  (when-let ((customs (cdr (assq theme themes-config-customizations))))
    (dolist (custom customs) (set (car custom) (cdr custom)))))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Theme Discovery Functions
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (defun
  themes-utils--get-available-doom-themes () "Get a list of all available doom themes."
  (sort
   (seq-filter
    (lambda (theme) (string-match-p "^doom-" (symbol-name theme))) (custom-available-themes))
   (lambda (a b) (string< (symbol-name a) (symbol-name b)))))

 (defun
  themes-utils--get-other-themes
  ()
  "Get a list of other (non-doom) themes that work well."
  '(wombat tango-dark leuven))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Interactive Theme Functions
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
       (mapcar #'symbol-name (themes-utils--get-available-doom-themes))
       (mapcar #'symbol-name (themes-utils--get-other-themes)))
      nil t nil nil "doom-zenburn"))))
  (core-message-theme "Interactive theme switch requested: %s" theme)
  (setq themes-config-preferred-theme theme)
  (themes-config-load-configured-theme)
  (core-message-success "Theme switched to: %s" theme))

 ;;;###autoload
 (defun
  theme-utils-list-themes () "List all available themes in a selectable buffer." (interactive)
  (let* ((doom-themes (themes-utils--get-available-doom-themes))
         (other-themes (themes-utils--get-other-themes))
         (current-theme (car custom-enabled-themes))
         (buffer-name "*Available Themes*")
         (lines '())
         (max-width 0))
    (core-message-theme "Opening theme browser...")

    ;; Collect all lines and calculate max width
    (push "Available Themes:" lines)
    (push "==================" lines)
    (push "" lines)
    (push "Click on a theme name or press 'RET' to select it, 'q' to quit." lines)
    (push "" lines)
    (push "DOOM THEMES:" lines)
    (dolist
     (theme doom-themes)
     (let ((line
            (if (eq theme current-theme) (format "-> %s (current)" theme) (format "   %s" theme))))
       (push line lines)
       (setq max-width (max max-width (length line)))))
    (push "" lines)
    (push "OTHER THEMES:" lines)
    (dolist
     (theme other-themes)
     (let ((line
            (if (eq theme current-theme) (format "-> %s (current)" theme) (format "   %s" theme))))
       (push line lines)
       (setq max-width (max max-width (length line)))))

    ;; Update max-width for header lines
    (setq
     max-width
     (max
      max-width
      (length "Available Themes:")
      (length "==================")
      (length "Click on a theme name or press 'RET' to select it, 'q' to quit.")
      (length "DOOM THEMES:")
      (length "OTHER THEMES:")))

    ;; Add some padding
    (setq max-width (+ max-width 4))

    (with-output-to-temp-buffer
     buffer-name (dolist (line (reverse lines)) (princ line) (princ "\n")))

    (with-current-buffer
     buffer-name (goto-char (point-min))

     ;; Resize window to fit content
     (let ((window (get-buffer-window buffer-name)))
       (when
        window
        (with-selected-window
         window
         (fit-window-to-buffer window nil nil max-width max-width)
         (shrink-window-horizontally (max 0 (- (window-width) max-width))))))

     ;; Function to select theme from current line
     (let ((select-theme-fn
            (lambda
             () (interactive)
             (let ((line (thing-at-point 'line t)))
               (when
                (string-match "\\(?:-> \\|   \\)\\([a-z0-9-]+\\)" line)
                (let ((theme (intern (match-string 1 line))))
                  (core-message-theme "Theme selection: %s" theme)
                  (setq themes-config-preferred-theme theme)
                  (themes-config-load-configured-theme)
                  (core-message-success
                   "Switched to theme: %s (buffer stays open for testing)" theme)
                  ;; Update the buffer to show new current theme
                  (theme-utils-list-themes)))))))

       ;; Keyboard bindings
       (local-set-key (kbd "RET") select-theme-fn)
       (local-set-key (kbd "q") 'quit-window)
       (local-set-key (kbd "C-g") 'quit-window)

       (setq buffer-read-only t)
       (goto-char (point-min)))))))

;; Make this module available for loading with (require 'themes-utils)
(provide 'themes-utils)

;;; themes-utils.el ends here
