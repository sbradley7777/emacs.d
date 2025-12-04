;;; command-palette-init.el --- Command Palette Initialization -*- lexical-binding: t -*-
;;; Commentary:
;; Main entry point for the Command Palette system.
;; Contains constants, variables, keymap, and initialization logic.

;;; Code:
(require 'core-constants)
(require 'core-utils)
(require 'logging-init)
(require 'ring)
(require 'command-palette-defaults)
(require 'command-palette-constants)

;; Forward declarations
(declare-function command-palette--render-content "command-palette-views")
(declare-function command-palette--calculate-window-width "command-palette-actions")
(declare-function command-palette--load-favorites "command-palette-data")
(declare-function command-palette--load-diagnostics "command-palette-data")
(declare-function command-palette--load-history "command-palette-data")
(declare-function command-palette--save-favorites "command-palette-data")
(declare-function command-palette--save-diagnostics "command-palette-data")
(declare-function command-palette--save-history "command-palette-data")
(declare-function command-palette--track-command "command-palette-actions")
(declare-function command-palette-switch-to-favorites "command-palette-views")
(declare-function command-palette-switch-to-diagnostics "command-palette-views")
(declare-function command-palette-switch-to-history "command-palette-views")
(declare-function command-palette-next-view "command-palette-views")
(declare-function command-palette-previous-view "command-palette-views")
(declare-function command-palette--add-favorite "command-palette-actions")
(declare-function command-palette--remove-favorite "command-palette-actions")
(declare-function command-palette--clear-history "command-palette-actions")
(declare-function command-palette--validate-commands "command-palette-actions")
(declare-function user-close-exclusive-side-windows "user-utils")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar user-command-palette-window nil "Window displaying the command palette.")
(defvar
 user--command-palette-history nil "Ring buffer storing recently executed commands from palette.")
(defvar
 user-command-palette-favorites
 nil
 "List of favorite commands displayed in the palette.  Loaded from file or defaults.")
(defvar
 user-command-palette-diagnostics
 nil
 "List of diagnostic commands displayed in the palette.  Loaded from file or defaults.")
(defvar
 user--command-palette-previous-window
 nil
 "Window that was active before opening the command palette.")
(defvar
 user--command-palette-current-view command-palette--default-view
 "Current view displayed in command palette.
Possible values: \\='favorites, \\='diagnostics, \\='history.")
(defvar user--command-palette-mx-flag nil "Non-nil means `M-x' was invoked.")
(defvar
 user-command-palette-mode-map
 (let ((map (make-sparse-keymap)))
   (define-key map (kbd "q") 'toggle-command-palette)
   (define-key map (kbd "a") 'command-palette--add-favorite)
   (define-key map (kbd "r") 'command-palette--remove-favorite)
   (define-key map (kbd "c") 'command-palette--clear-history)
   (define-key map (kbd "v") 'command-palette--validate-commands)
   (define-key map (kbd "f") 'command-palette-switch-to-favorites)
   (define-key map (kbd "d") 'command-palette-switch-to-diagnostics)
   (define-key map (kbd "h") 'command-palette-switch-to-history)
   (define-key map (kbd "n") 'command-palette-next-view)
   (define-key map (kbd "p") 'command-palette-previous-view)
   map)
 "Keymap for command palette buffer.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 toggle-command-palette ()
 "Toggle the command palette side window display.

Opens the command palette in a side window showing the current view (defaults to Favorites).
If already open, closes it.  When opening, automatically closes other exclusive
side windows (Flymake diagnostics, Imenu-list)."
 (interactive)
 (if
  (and user-command-palette-window (window-live-p user-command-palette-window))
  (progn (delete-window user-command-palette-window) (setq user-command-palette-window nil))
  (when (fboundp 'user-close-exclusive-side-windows) (user-close-exclusive-side-windows))
  (setq user--command-palette-current-view command-palette--default-view)
  (setq user--command-palette-previous-window (selected-window))
  (let* ((buffer (get-buffer-create command-palette-buffer-name))
         (window-width nil)
         (first-cmd-pos nil))
    (with-current-buffer
     buffer
     (let ((inhibit-read-only t))
       (erase-buffer)
       (setq first-cmd-pos (command-palette--render-content))
       (setq window-width (command-palette--calculate-window-width)))
     (setq buffer-read-only t)
     (setq-local cursor-type nil)
     (use-local-map user-command-palette-mode-map)
     (hl-line-mode 1))
    (setq
     user-command-palette-window
     (display-buffer-in-side-window
      buffer `((side . right) (window-width . ,window-width) (slot . 0))))
    (select-window user-command-palette-window)
    (if first-cmd-pos (goto-char first-cmd-pos) (goto-char (point-min))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Initialization
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Provide first to avoid recursive requires
(provide 'command-palette-init)

;; Load other modules AFTER providing and AFTER variables are defined
(require 'command-palette-data)
(require 'command-palette-actions)
(require 'command-palette-views)

;; Initialize ring buffer
(setq user--command-palette-history (make-ring command-palette-history-size))

;; Load saved data
(command-palette--load-favorites)
(command-palette--load-diagnostics)
(command-palette--load-history)

;; Enable M-x command tracking
(add-hook 'post-command-hook #'command-palette--track-command)

;; Save on exit
(add-hook 'kill-emacs-hook #'command-palette--save-history)
(add-hook 'kill-emacs-hook #'command-palette--save-favorites)
(add-hook 'kill-emacs-hook #'command-palette--save-diagnostics)

(logging-success "Command palette loaded!")

;;; command-palette-init.el ends here
